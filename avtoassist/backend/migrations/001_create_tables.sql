-- AvtoAssist Database Schema
-- PostgreSQL + PostGIS extension

-- PostGIS extension (geo ma'lumotlar uchun)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users jadvali
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'provider')),
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- Providers jadvali
CREATE TABLE IF NOT EXISTS providers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    service_type VARCHAR(50) NOT NULL CHECK (service_type IN (
        'mechanic', 'fuel_delivery', 'car_wash', 
        'parts_seller', 'workshop', 'tow_truck'
    )),
    business_name VARCHAR(200),
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    current_location GEOMETRY(Point, 4326),
    last_location_update TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_providers_user_id ON providers(user_id);
CREATE INDEX idx_providers_service_type ON providers(service_type);
CREATE INDEX idx_providers_available ON providers(is_available);
CREATE INDEX idx_providers_location ON providers USING GIST(current_location);

-- Orders jadvali
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider_id INTEGER REFERENCES providers(id) ON DELETE SET NULL,
    service_type VARCHAR(50) NOT NULL,
    description TEXT,
    pickup_location GEOMETRY(Point, 4326) NOT NULL,
    destination_location GEOMETRY(Point, 4326),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
    )),
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    completed_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_orders_provider ON orders(provider_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_service_type ON orders(service_type);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_orders_pickup_location ON orders USING GIST(pickup_location);

-- Service Areas (providerlar qaysi hududlarda xizmat ko'rsatadi)
CREATE TABLE IF NOT EXISTS service_areas (
    id SERIAL PRIMARY KEY,
    provider_id INTEGER NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
    area_name VARCHAR(100) NOT NULL,
    area_polygon GEOMETRY(Polygon, 4326) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_service_areas_provider ON service_areas(provider_id);
CREATE INDEX idx_service_areas_polygon ON service_areas USING GIST(area_polygon);

-- Reviews jadvali
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    provider_id INTEGER NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
    client_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reviews_provider ON reviews(provider_id);
CREATE INDEX idx_reviews_client ON reviews(client_id);
CREATE INDEX idx_reviews_order ON reviews(order_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Workshops (ustaxonalar)
CREATE TABLE IF NOT EXISTS workshops (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    address TEXT NOT NULL,
    location GEOMETRY(Point, 4326) NOT NULL,
    phone VARCHAR(20),
    working_hours VARCHAR(100),
    services TEXT[],
    rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workshops_location ON workshops USING GIST(location);
CREATE INDEX idx_workshops_rating ON workshops(rating DESC);

-- Parts (ehtiyot qismlar)
CREATE TABLE IF NOT EXISTS parts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    price DECIMAL(10,2),
    shop_name VARCHAR(200),
    shop_location GEOMETRY(Point, 4326),
    in_stock BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_parts_category ON parts(category);
CREATE INDEX idx_parts_name ON parts(name);
CREATE INDEX idx_parts_in_stock ON parts(in_stock);
CREATE INDEX idx_parts_shop_location ON parts USING GIST(shop_location);

-- Notifications jadvali
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- Updated_at trigger funksiyasi
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggerlar
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_providers_updated_at
    BEFORE UPDATE ON providers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_parts_updated_at
    BEFORE UPDATE ON parts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Demo data qo'shish (optional, test uchun)
-- Bu yerda demo foydalanuvchilar va providerlar qo'shiladi
