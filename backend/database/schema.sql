CREATE DATABASE IF NOT EXISTS bank_soal
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bank_soal;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NULL,
  email VARCHAR(191) NOT NULL,
  password_hash VARCHAR(255) NULL,
  full_name VARCHAR(120) NULL,
  role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
  avatar_url VARCHAR(500) NULL,
  provider ENUM('local', 'google') NOT NULL DEFAULT 'local',
  provider_id VARCHAR(191) NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  email_verified_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_provider (provider, provider_id),
  INDEX idx_users_provider_id (provider_id)
) ENGINE=InnoDB;

SET @role_column_exists = (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND column_name = 'role'
);
SET @add_role_sql = IF(
  @role_column_exists = 0,
  "ALTER TABLE users ADD COLUMN role ENUM('user', 'admin') NOT NULL DEFAULT 'user' AFTER full_name",
  'SELECT 1'
);
PREPARE add_role_statement FROM @add_role_sql;
EXECUTE add_role_statement;
DEALLOCATE PREPARE add_role_statement;

INSERT INTO users (
  username,
  email,
  password_hash,
  full_name,
  role,
  provider,
  is_active
)
VALUES
  (
    'admin',
    'admin@banksoal.test',
    '$2b$12$9gEhquFPofk5rzj3huTdjuQ1pff4PzojwmDt5h2kJSJXEzWuAY..m',
    'Administrator Bank Soal',
    'admin',
    'local',
    TRUE
  ),
  (
    'user',
    'user@banksoal.test',
    '$2b$12$KvemI2knymLIoWrptg8mNeLlUEgDRuxwa6EQgp3VfVFvnNgOfWLlK',
    'Pengguna Bank Soal',
    'user',
    'local',
    TRUE
  )
ON DUPLICATE KEY UPDATE
  password_hash = VALUES(password_hash),
  full_name = VALUES(full_name),
  role = VALUES(role),
  provider = VALUES(provider),
  is_active = VALUES(is_active);

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_refresh_token_hash (token_hash),
  INDEX idx_refresh_user (user_id),
  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reset_token_hash (token_hash),
  INDEX idx_reset_user (user_id),
  CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;