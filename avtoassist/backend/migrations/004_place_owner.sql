-- Xizmat ko'rsatuvchilar o'z manzilini qo'sha olishi uchun egasi ustuni
ALTER TABLE service_places ADD COLUMN IF NOT EXISTS owner_user_id INTEGER;
