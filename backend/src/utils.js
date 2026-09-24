const crypto = require('crypto');

function createOpaqueToken(bytes = 48) {
  return crypto.randomBytes(bytes).toString('hex');
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function publicUser(user) {
  return {
    id: user.id,
    username: user.username,
    email: user.email,
    fullName: user.full_name,
    role: user.role || 'user',
    avatarUrl: user.avatar_url,
    provider: user.provider,
  };
}

module.exports = { createOpaqueToken, hashToken, publicUser };