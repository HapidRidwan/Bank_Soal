const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('./db');
const { createOpaqueToken, hashToken, publicUser } = require('./utils');

function requireSecret(name) {
  const value = process.env[name];
  if (!value || value.startsWith('ganti-dengan')) {
    throw new Error(`${name} belum dikonfigurasi`);
  }
  return value;
}

function createAccessToken(user) {
  return jwt.sign(
    { sub: String(user.id), role: user.role, email: user.email },
    requireSecret('JWT_ACCESS_SECRET'),
    { expiresIn: process.env.JWT_ACCESS_EXPIRES || '15m' },
  );
}

async function createRefreshToken(userId) {
  const token = createOpaqueToken();
  const days = Number(process.env.JWT_REFRESH_EXPIRES_DAYS || 30);
  const expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000);

  await pool.execute(
    `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
     VALUES (:userId, :tokenHash, :expiresAt)`,
    { userId, tokenHash: hashToken(token), expiresAt },
  );

  return token;
}

async function issueTokens(user) {
  return {
    accessToken: createAccessToken(user),
    refreshToken: await createRefreshToken(user.id),
    user: publicUser(user),
  };
}

function verifyAccessToken(token) {
  return jwt.verify(token, requireSecret('JWT_ACCESS_SECRET'));
}

module.exports = {
  bcrypt,
  createAccessToken,
  createRefreshToken,
  issueTokens,
  verifyAccessToken,
  requireSecret,
};