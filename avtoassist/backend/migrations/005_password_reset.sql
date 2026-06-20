-- Parolni SMS orqali tiklash uchun kod ustunlari
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code_expires TIMESTAMP;
