const { verifyAccessToken } = require('./auth');

function authenticate(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Token akses diperlukan.' });
  }

  try {
    req.auth = verifyAccessToken(token);
    return next();
  } catch (_error) {
    return res.status(401).json({ message: 'Token akses tidak valid atau sudah kedaluwarsa.' });
  }
}

module.exports = { authenticate };