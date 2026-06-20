-- Demo ma'lumotlar (testing uchun)
-- Parollar: "password123" - barcha demo userlar uchun

-- Demo Users (password: password123)
INSERT INTO users (phone, password_hash, full_name, role, phone_verified) VALUES
('+998901234567', '$2b$10$rKvV8p3mZ2LXxN5R6YGWxOJ5xZ8QKx5zZ8wZ5wZ5wZ5wZ5wZ5wZ5w', 'Ali Valiyev', 'client', true),
('+998902345678', '$2b$10$rKvV8p3mZ2LXxN5R6YGWxOJ5xZ8QKx5zZ8wZ5wZ5wZ5wZ5wZ5wZ5w', 'Bobur Usmonov', 'provider', true),
('+998903456789', '$2b$10$rKvV8p3mZ2LXxN5R6YGWxOJ5xZ8QKx5zZ8wZ5wZ5wZ5wZ5wZ5wZ5w', 'Dilnoza Karimova', 'client', true),
('+998904567890', '$2b$10$rKvV8p3mZ2LXxN5R6YGWxOJ5xZ8QKx5zZ8wZ5wZ5wZ5wZ5wZ5wZ5w', 'Eldor Toshmatov', 'provider', true),
('+998905678901', '$2b$10$rKvV8p3mZ2LXxN5R6YGWxOJ5xZ8QKx5zZ8wZ5wZ5wZ5wZ5wZ5wZ5w', 'Farida Ahmedova', 'provider', true);

-- Demo Providers
INSERT INTO providers (user_id, service_type, business_name, rating, total_orders, is_available, current_location) VALUES
(2, 'mechanic', 'Bobur AvtoServis', 4.7, 156, true, ST_GeomFromText('POINT(69.2401 41.3111)', 4326)),
(4, 'fuel_delivery', 'Tezkor Yoqilg''i', 4.9, 89, true, ST_GeomFromText('POINT(69.2501 41.3211)', 4326)),
(5, 'tow_truck', 'Evakuator 24/7', 4.5, 234, true, ST_GeomFromText('POINT(69.2301 41.3011)', 4326));

-- Demo Workshops
INSERT INTO workshops (name, address, location, phone, working_hours, services, rating) VALUES
('AvtoRemont Premium', 'Toshkent, Yunusobod tumani, Amir Temur ko''chasi 12', 
 ST_GeomFromText('POINT(69.2901 41.3511)', 4326), '+998712345678', '08:00-20:00', 
 ARRAY['Dvigatel ta''miri', 'Diagnostika', 'Elektrika', 'Konditsioner'], 4.8),
('Car Service Master', 'Toshkent, Chilonzor tumani, Bunyodkor 15', 
 ST_GeomFromText('POINT(69.2101 41.2811)', 4326), '+998712345679', '09:00-19:00', 
 ARRAY['Kuzov ta''miri', 'Bo''yoq', 'Polirovka'], 4.6),
('Express Auto Center', 'Toshkent, Mirzo Ulug''bek tumani, Parkent ko''chasi 8', 
 ST_GeomFromText('POINT(69.3201 41.3411)', 4326), '+998712345680', '08:00-22:00', 
 ARRAY['Tez xizmat', 'Moy almashtirish', 'Filtrlar', 'Tormozlar'], 4.9);

-- Demo Parts
INSERT INTO parts (name, category, description, price, shop_name, shop_location, in_stock) VALUES
('Moy filtri Universal', 'Filtrlar', 'Har qanday avtomobil uchun', 45000, 'AvtoZapchast №1', 
 ST_GeomFromText('POINT(69.2701 41.3311)', 4326), true),
('Tormoz kolodkalari (oldingi)', 'Tormoz tizimi', 'Toyota, Chevrolet uchun', 280000, 'AutoParts Center',
 ST_GeomFromText('POINT(69.2601 41.3111)', 4326), true),
('Akkumulyator 60Ah', 'Elektrika', 'Mutlu 60Ah, 540A', 650000, 'Elektro Avto',
 ST_GeomFromText('POINT(69.2801 41.3211)', 4326), true),
('Havo filtri', 'Filtrlar', 'Mann Filter, original sifat', 65000, 'AvtoZapchast №1',
 ST_GeomFromText('POINT(69.2701 41.3311)', 4326), true),
('Svechalar (to''plam)', 'Dvigatel', 'NGK Platinum, 4 dona', 180000, 'AutoParts Center',
 ST_GeomFromText('POINT(69.2601 41.3111)', 4326), true),
('Yog'' 10W-40 (4L)', 'Moylar', 'Shell Helix HX7, yarim sintetik', 320000, 'Moy Markazi',
 ST_GeomFromText('POINT(69.2501 41.3011)', 4326), true);

-- Demo Orders
INSERT INTO orders (client_id, provider_id, service_type, description, pickup_location, status, price, created_at) VALUES
(1, 1, 'mechanic', 'Dvigatelda notekis ishlamoqda, diagnostika kerak', 
 ST_GeomFromText('POINT(69.2451 41.3161)', 4326), 'completed', 150000, NOW() - INTERVAL '2 days'),
(3, 2, 'fuel_delivery', 'Benzin tugadi, 20 litr AI-92 kerak', 
 ST_GeomFromText('POINT(69.2551 41.3261)', 4326), 'completed', 250000, NOW() - INTERVAL '1 day');

-- Demo Reviews
INSERT INTO reviews (order_id, provider_id, client_id, rating, comment) VALUES
(1, 1, 1, 5, 'Juda tez va sifatli xizmat. Rahmat!'),
(2, 2, 3, 5, 'Ajoyib xizmat, 15 daqiqada yetib keldi.');
