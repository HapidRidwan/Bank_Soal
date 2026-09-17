const express = require('express');
const { OAuth2Client } = require('google-auth-library');
const pool = require('../db');
const {
  bcrypt,
  issueTokens,
  createRefreshToken,
  verifyAccessToken,
} = require('../auth');
const { authenticate } = require('../middleware');
const { createOpaqueToken, hashToken, publicUser } = require('../utils');

const router = express.Router();
const googleClient = new OAuth2Client();

function cleanEmail(value) {
  return String(value || '').trim().toLowerCase();
}

function requiredString(value, field) {
  const result = String(value || '').trim();
  if (!result) {
    const error = new Error(`${field} wajib diisi.`);
    error.status = 400;
    throw error;
  }
  return result;
}

function validatePassword(password) {
  if (password.length < 8) {
    const error = new Error('Password minimal 8 karakter.');
    error.status = 400;
    throw error;
  }
}

router.post('/register', async (req, res, next) => {
  try {
    const username = requiredString(req.body.username, 'Username');
    const email = cleanEmail(requiredString(req.body.email, 'Email'));
    const password = requiredString(req.body.password, 'Password');
    const fullName = String(req.body.fullName || username).trim();
    validatePassword(password);

    if (!/^\S+@\S+\.\S+$/.test(email)) {
      return res.status(400).json({ message: 'Format email tidak valid.' });
    }

    const [existing] = await pool.execute(
      'SELECT id FROM users WHERE email = :email OR username = :username LIMIT 1',
      { email, username },
    );
    if (existing.length) {
      return res.status(409).json({ message: 'Email atau username sudah digunakan.' });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const [result] = await pool.execute(
      `INSERT INTO users (username, email, password_hash, full_name, provider)
       VALUES (:username, :email, :passwordHash, :fullName, 'local')`,
      { username, email, passwordHash, fullName },
    );
    const [rows] = await pool.execute('SELECT * FROM users WHERE id = :id', { id: result.insertId });
    return res.status(201).json(await issueTokens(rows[0]));
  } catch (error) {
    return next(error);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const identity = requiredString(req.body.identity, 'Email atau username');
    const password = requiredString(req.body.password, 'Password');
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE email = :identity OR username = :identity LIMIT 1',
      { identity: identity.toLowerCase() },
    );
    const user = rows[0];
    const valid = user && user.password_hash && await bcrypt.compare(password, user.password_hash);
    if (!valid || !user.is_active) {
      return res.status(401).json({ message: 'Email/username atau password salah.' });
    }
    return res.json(await issueTokens(user));
  } catch (error) {
    return next(error);
  }
});

router.post('/google', async (req, res, next) => {
  try {
    const idToken = requiredString(req.body.idToken, 'Google ID token');
    const clientId = process.env.GOOGLE_CLIENT_ID;
    if (!clientId) {
      return res.status(503).json({ message: 'Google login belum dikonfigurasi di backend.' });
    }

    const ticket = await googleClient.verifyIdToken({ idToken, audience: clientId });
    const payload = ticket.getPayload();
    if (!payload || !payload.sub || !payload.email || payload.email_verified !== true) {
      return res.status(401).json({ message: 'Google token tidak valid atau email belum terverifikasi.' });
    }

    const email = cleanEmail(payload.email);
    const [existingRows] = await pool.execute(
      'SELECT * FROM users WHERE provider = \'google\' AND provider_id = :providerId LIMIT 1',
      { providerId: payload.sub },
    );
    let user = existingRows[0];

    if (!user) {
      const [emailRows] = await pool.execute('SELECT * FROM users WHERE email = :email LIMIT 1', { email });
      user = emailRows[0];
      if (user) {
        await pool.execute(
          `UPDATE users SET provider = 'google', provider_id = :providerId,
           full_name = COALESCE(NULLIF(full_name, ''), :fullName), avatar_url = :avatarUrl,
           email_verified_at = COALESCE(email_verified_at, UTC_TIMESTAMP())
           WHERE id = :id`,
          {
            providerId: payload.sub,
            fullName: payload.name || email.split('@')[0],
            avatarUrl: payload.picture || null,
            id: user.id,
          },
        );
      } else {
        const username = `google_${payload.sub.slice(0, 20)}`;
        const [result] = await pool.execute(
          `INSERT INTO users (username, email, full_name, avatar_url, provider, provider_id, email_verified_at)
           VALUES (:username, :email, :fullName, :avatarUrl, 'google', :providerId, UTC_TIMESTAMP())`,
          {
            username,
            email,
            fullName: payload.name || email.split('@')[0],
            avatarUrl: payload.picture || null,
            providerId: payload.sub,
          },
        );
        user = { id: result.insertId };
      }
      const [freshRows] = await pool.execute('SELECT * FROM users WHERE id = :id', { id: user.id });
      user = freshRows[0];
    }

    if (!user.is_active) {
      return res.status(403).json({ message: 'Akun sedang dinonaktifkan.' });
    }
    return res.json(await issueTokens(user));
  } catch (error) {
    return next(error);
  }
});

router.post('/refresh', async (req, res, next) => {
  try {
    const refreshToken = requiredString(req.body.refreshToken, 'Refresh token');
    const [rows] = await pool.execute(
      `SELECT u.*, rt.id AS refresh_id FROM refresh_tokens rt
       INNER JOIN users u ON u.id = rt.user_id
       WHERE rt.token_hash = :tokenHash AND rt.revoked_at IS NULL AND rt.expires_at > UTC_TIMESTAMP()
       LIMIT 1`,
      { tokenHash: hashToken(refreshToken) },
    );
    const user = rows[0];
    if (!user || !user.is_active) {
      return res.status(401).json({ message: 'Refresh token tidak valid atau sudah kedaluwarsa.' });
    }
    await pool.execute('UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE id = :id', {
      id: user.refresh_id,
    });
    return res.json(await issueTokens(user));
  } catch (error) {
    return next(error);
  }
});

router.post('/logout', async (req, res, next) => {
  try {
    const refreshToken = requiredString(req.body.refreshToken, 'Refresh token');
    await pool.execute(
      'UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE token_hash = :tokenHash',
      { tokenHash: hashToken(refreshToken) },
    );
    return res.json({ message: 'Logout berhasil.' });
  } catch (error) {
    return next(error);
  }
});

router.get('/me', authenticate, async (req, res, next) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM users WHERE id = :id LIMIT 1', { id: req.auth.sub });
    if (!rows[0] || !rows[0].is_active) {
      return res.status(404).json({ message: 'User tidak ditemukan.' });
    }
    return res.json({ user: publicUser(rows[0]) });
  } catch (error) {
    return next(error);
  }
});

router.post('/forgot-password', async (req, res, next) => {
  try {
    const email = cleanEmail(requiredString(req.body.email, 'Email'));
    const [rows] = await pool.execute('SELECT id FROM users WHERE email = :email LIMIT 1', { email });
    const response = { message: 'Jika email terdaftar, instruksi reset password telah dibuat.' };

    if (rows[0]) {
      const token = createOpaqueToken();
      const minutes = Number(process.env.RESET_TOKEN_EXPIRES_MINUTES || 30);
      const expiresAt = new Date(Date.now() + minutes * 60 * 1000);
      await pool.execute(
        `INSERT INTO password_reset_tokens (user_id, token_hash, expires_at)
         VALUES (:userId, :tokenHash, :expiresAt)`,
        { userId: rows[0].id, tokenHash: hashToken(token), expiresAt },
      );
      if (process.env.NODE_ENV !== 'production') response.resetToken = token;
    }
    return res.json(response);
  } catch (error) {
    return next(error);
  }
});

router.post('/reset-password', async (req, res, next) => {
  try {
    const token = requiredString(req.body.token, 'Reset token');
    const password = requiredString(req.body.password, 'Password baru');
    validatePassword(password);
    const [rows] = await pool.execute(
      `SELECT id, user_id FROM password_reset_tokens
       WHERE token_hash = :tokenHash AND used_at IS NULL AND expires_at > UTC_TIMESTAMP()
       LIMIT 1`,
      { tokenHash: hashToken(token) },
    );
    if (!rows[0]) return res.status(400).json({ message: 'Reset token tidak valid atau sudah kedaluwarsa.' });

    const passwordHash = await bcrypt.hash(password, 12);
    await pool.query('START TRANSACTION');
    try {
      await pool.execute('UPDATE users SET password_hash = :passwordHash, provider = IF(provider = \'google\', provider, \'local\') WHERE id = :userId', { passwordHash, userId: rows[0].user_id });
      await pool.execute('UPDATE password_reset_tokens SET used_at = UTC_TIMESTAMP() WHERE id = :id', { id: rows[0].id });
      await pool.execute('UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE user_id = :userId AND revoked_at IS NULL', { userId: rows[0].user_id });
      await pool.query('COMMIT');
    } catch (error) {
      await pool.query('ROLLBACK');
      throw error;
    }
    return res.json({ message: 'Password berhasil diubah.' });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;