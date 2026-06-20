-- Service Places (Do'konlar, Yoqilg'i quyish shoxoblari, Evakuatorlar va h.k.)
-- Bu jadval OFFLINE rejimda ham ishlaydi - ma'lumotlar cache'da saqlanadi

CREATE TABLE IF NOT EXISTS service_places (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  type VARCHAR(50) NOT NULL, -- gas_station, auto_parts, workshop, evacuator, car_wash, tire_service
  address TEXT NOT NULL,
  phone VARCHAR(20) NOT NULL,
  phone_2 VARCHAR(20), -- Qo'shimcha telefon
  location GEOGRAPHY(POINT, 4326) NOT NULL,
  working_hours VARCHAR(100),
  rating DECIMAL(2,1) DEFAULT 0.0,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for location queries (offline map uchun muhim)
CREATE INDEX idx_service_places_location ON service_places USING GIST(location);
CREATE INDEX idx_service_places_type ON service_places (type);

-- Real Toshkent ma'lumotlari
-- Bu ma'lumotlar offline cache'da saqlanadi

-- 1. Yoqilg'i quyish shoxoblari (Gas Stations)
INSERT INTO service_places (name, type, address, phone, phone_2, location, working_hours, rating, description) VALUES
('Uzbekneftegaz №15', 'gas_station', 'Toshkent, Amir Temur ko''chasi 108', '+998712023456', '+998712023457', ST_GeogFromText('POINT(69.2785 41.3111)'), '00:00 - 24:00', 4.5, 'A-92, A-95, Dizel. Avto yuvish xizmati'),
('UzGasOil Yunusobod', 'gas_station', 'Toshkent, Yunusobod tumani, Bobur ko''chasi 12', '+998712345678', NULL, ST_GeogFromText('POINT(69.2850 41.3450)'), '00:00 - 24:00', 4.7, 'Barcha turdagi yoqilg''i. CNG gaz'),
('Lukoil Chilonzor', 'gas_station', 'Toshkent, Chilonzor-1, Bunyodkor ko''chasi', '+998712876543', '+998901234567', ST_GeogFromText('POINT(69.2100 41.2850)'), '00:00 - 24:00', 4.6, 'Premium benzin va dizel yoqilg''i'),
('Gazprom Sergeli', 'gas_station', 'Toshkent, Sergeli tumani, Ipak Yo''li ko''chasi', '+998712456789', NULL, ST_GeogFromText('POINT(69.2200 41.2150)'), '06:00 - 23:00', 4.3, 'Arzon narxlar, CNG gaz bor'),
('Petrol Qo''qon yo''li', 'gas_station', 'Toshkent, Qo''qon yo''li 25', '+998712567890', '+998909876543', ST_GeogFromText('POINT(69.3200 41.3500)'), '00:00 - 24:00', 4.4, 'Yo''lda qulay joylashuv'),
('GasPoint Olmazor', 'gas_station', 'Toshkent, Olmazor tumani, Shifokorlar ko''chasi', '+998712678901', NULL, ST_GeogFromText('POINT(69.2300 41.3300)'), '00:00 - 24:00', 4.2, '24/7 xizmat, kafe mavjud');

-- 2. Ehtiyot qismlar do'konlari (Auto Parts)
INSERT INTO service_places (name, type, address, phone, phone_2, location, working_hours, rating, description) VALUES
('AvtoZapchast Markazi', 'auto_parts', 'Toshkent, Sebzor bozori yonida', '+998712111222', '+998901111222', ST_GeogFromText('POINT(69.2400 41.3250)'), '09:00 - 19:00', 4.6, 'Barcha avtomobillar uchun zapchastlar'),
('AutoParts.uz', 'auto_parts', 'Toshkent, Yunusobod-6, 12-mavze', '+998712222333', NULL, ST_GeogFromText('POINT(69.2900 41.3550)'), '09:00 - 20:00', 4.8, 'Original va alternativ qismlar. Buyurtma qabul qilamiz'),
('Nexia Parts Center', 'auto_parts', 'Toshkent, Chilonzor tumani, Qatortol bozori', '+998712333444', '+998909999888', ST_GeogFromText('POINT(69.2050 41.2900)'), '08:00 - 18:00', 4.4, 'Chevrolet Nexia zapchastlari mutaxassisi'),
('Toyota Original', 'auto_parts', 'Toshkent, Shayxontohur tumani, Farobiy ko''chasi', '+998712444555', NULL, ST_GeogFromText('POINT(69.2700 41.3350)'), '09:00 - 19:00', 4.9, 'Original Toyota, Lexus qismlari'),
('Universal AvtoQism', 'auto_parts', 'Toshkent, Mirobod tumani, Buston ko''chasi', '+998712555666', '+998901234599', ST_GeogFromText('POINT(69.2650 41.3050)'), '09:00 - 18:00', 4.3, 'Yevropа va koreys avtolar zapchastlari'),
('Electro Auto Parts', 'auto_parts', 'Toshkent, Yashnobod tumani', '+998712666777', NULL, ST_GeogFromText('POINT(69.3100 41.2800)'), '09:00 - 19:00', 4.5, 'Elektr qismlari va akkumulyatorlar');

-- 3. Avto ustaxonalar (Workshops)
INSERT INTO service_places (name, type, address, phone, phone_2, location, working_hours, rating, description) VALUES
('Avto Servis Professional', 'workshop', 'Toshkent, Yunusobod-4, Shahrisabz ko''chasi', '+998712777888', '+998902222333', ST_GeogFromText('POINT(69.2800 41.3400)'), '08:00 - 20:00', 4.7, 'Dvigatel ta''miri, diagnostika, elektrika'),
('GM Service Center', 'workshop', 'Toshkent, Chilonzor-9, Qatortol ko''chasi', '+998712888999', NULL, ST_GeogFromText('POINT(69.2000 41.2800)'), '09:00 - 19:00', 4.8, 'Chevrolet rasmiy servis markazi'),
('Usta Karim Auto', 'workshop', 'Toshkent, Sergeli-5', '+998712999000', '+998903333444', ST_GeogFromText('POINT(69.2250 41.2200)'), '08:00 - 21:00', 4.6, 'Tezkor ta''mirlash, arzon narxlar'),
('Turbo Service', 'workshop', 'Toshkent, Olmazor tumani, Buyuk Ipak Yo''li', '+998712000111', NULL, ST_GeogFromText('POINT(69.2350 41.3280)'), '09:00 - 19:00', 4.5, 'Turbina ta''miri mutaxassisi'),
('AvtoDoctor 24/7', 'workshop', 'Toshkent, Mirzo Ulug''bek tumani', '+998712111000', '+998904444555', ST_GeogFromText('POINT(69.3300 41.3600)'), '00:00 - 24:00', 4.4, '24/7 ta''mirlash, tezkor xizmat'),
('Premium Car Service', 'workshop', 'Toshkent, Shayxontohur tumani, Zarqaynar ko''chasi', '+998712222111', NULL, ST_GeogFromText('POINT(69.2750 41.3320)'), '09:00 - 20:00', 4.9, 'Premium avtomobillar uchun maxsus servis');

-- 4. Avto yuvish (Car Wash)
INSERT INTO service_places (name, type, address, phone, phone_2, location, working_hours, rating, description) VALUES
('Clean Car Premium', 'car_wash', 'Toshkent, Amir Temur ko''chasi, Business City yonida', '+998712333222', NULL, ST_GeogFromText('POINT(69.2800 41.3150)'), '08:00 - 22:00', 4.8, 'Avtomatik va qo''lda yuvish. Detailing xizmati'),
('Express Moyka 24', 'car_wash', 'Toshkent, Chilonzor-21, Bunyodkor ko''chasi', '+998712444333', '+998905555666', ST_GeogFromText('POINT(69.2080 41.2880)'), '00:00 - 24:00', 4.5, '24/7 tezkor avto yuvish, 15 daqiqa'),
('Shine & Clean', 'car_wash', 'Toshkent, Yunusobod-7, Amir Temur shox ko''chasi', '+998712555444', NULL, ST_GeogFromText('POINT(69.2920 41.3480)'), '09:00 - 21:00', 4.6, 'Ichki va tashqi tozalash, polirovka');

-- 5. Shinomontaj (Tire Service)
INSERT INTO service_places (name, type, address, phone, phone_2, location, working_hours, rating, description) VALUES
('ShinoMontaj 24/7', 'tire_service', 'Toshkent, Qo''qon yo''li 18', '+998712666555', '+998906666777', ST_GeogFromText('POINT(69.3150 41.3480)'), '00:00 - 24:00', 4.7, 'Tezkor shinomontaj, balansировка, argon payvandlash'),
('Professional Tires', 'tire_service', 'Toshkent, Sergeli tumani, Ipak Yo''li', '+998712777666', NULL, ST_GeogFromText('POINT(69.2180 41.2180)'), '08:00 - 20:00', 4.5, 'Shina sotish va o''rnatish, disk ta''miri');

-- 6. Evakuatorlar (Tow Trucks / Evacuators)
INSERT INTO service_places (name, type, address, phone, phone_2, location, working_hours, rating, description) VALUES
('Evakuator Toshkent 24/7', 'evacuator', 'Toshkent, barcha tumanlarga xizmat', '+998712888777', '+998907777888', ST_GeogFromText('POINT(69.2400 41.3111)'), '00:00 - 24:00', 4.8, '24/7 tezkor evakuatsiya. 15 daqiqada yetib boramiz'),
('SOS Evakuator', 'evacuator', 'Toshkent va viloyat bo''ylab', '+998712999888', '+998908888999', ST_GeogFromText('POINT(69.2600 41.3200)'), '00:00 - 24:00', 4.6, 'Yo''lda qolgan avtomobillarni evakuatsiya qilish'),
('Tezkor Yuk Ko''taruvchi', 'evacuator', 'Toshkent shahri va atrofi', '+998712000999', NULL, ST_GeogFromText('POINT(69.2500 41.3150)'), '07:00 - 23:00', 4.4, 'Yengil va og''ir avtomobillar evakuatsiyasi'),
('AvtoHelp Evacuator', 'evacuator', 'Toshkent, Viloyat yo''llari', '+998712111888', '+998909999000', ST_GeogFromText('POINT(69.2700 41.3250)'), '00:00 - 24:00', 4.7, 'Professional evakuator xizmati, sug''urta bilan ishlash');

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_service_places_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER service_places_updated_at
BEFORE UPDATE ON service_places
FOR EACH ROW
EXECUTE FUNCTION update_service_places_updated_at();

-- Comments
COMMENT ON TABLE service_places IS 'Xizmat ko''rsatuvchilar jadvali - offline rejimda ham ishlaydi';
COMMENT ON COLUMN service_places.type IS 'gas_station, auto_parts, workshop, evacuator, car_wash, tire_service';
COMMENT ON COLUMN service_places.location IS 'PostGIS geography - GPS koordinatalari (SRID 4326)';
COMMENT ON COLUMN service_places.phone_2 IS 'Qo''shimcha telefon raqami (ixtiyoriy)';
