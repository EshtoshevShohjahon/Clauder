# AvtoAssist Backend API

Node.js + Express + PostgreSQL + Socket.IO

## 🚀 Ishga tushirish

### 1. PostgreSQL o'rnatish

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib postgis

# MacOS (Homebrew)
brew install postgresql postgis

# PostgreSQL ishga tushirish
sudo service postgresql start  # Linux
brew services start postgresql # MacOS
```

### 2. Database yaratish

```bash
# PostgreSQL ga kirish
sudo -u postgres psql

# Database yaratish
CREATE DATABASE avtoassist;

# PostGIS extension qo'shish
\c avtoassist
CREATE EXTENSION postgis;

# User yaratish (optional)
CREATE USER avtoassist_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE avtoassist TO avtoassist_user;

# Chiqish
\q
```

### 3. Environment o'rnatish

```bash
cd backend

# .env faylini yaratish
cp .env.example .env

# .env faylini tahrirlash (database parolini kiriting)
nano .env
```

### 4. Dependencies o'rnatish

```bash
npm install
```

### 5. Database migration

```bash
npm run migrate
```

### 6. Server ishga tushirish

```bash
# Development mode (auto-restart)
npm run dev

# Production mode
npm start
```

Server ishga tushdi: http://localhost:3000

## 📡 API Endpoints

### Authentication

- `POST /api/auth/register` - Ro'yxatdan o'tish
- `POST /api/auth/login` - Kirish
- `POST /api/auth/verify-phone` - Telefon tasdiqlash
- `POST /api/auth/select-role` - Rol tanlash

### Orders

- `POST /api/orders` - Yangi so'rov yaratish
- `GET /api/orders` - So'rovlar ro'yxati
- `GET /api/orders/:id` - Bitta so'rov
- `POST /api/orders/:id/accept` - Qabul qilish (provider)
- `PUT /api/orders/:id/status` - Status o'zgartirish
- `POST /api/orders/:id/complete` - Yakunlash
- `POST /api/orders/:id/cancel` - Bekor qilish
- `POST /api/orders/:id/rate` - Baho berish

### Providers

- `GET /api/providers` - Providerlar ro'yxati
- `GET /api/providers/nearby` - Yaqin providerlar
- `GET /api/providers/:id` - Provider ma'lumotlari
- `GET /api/providers/workshops` - Ustaxonalar
- `GET /api/providers/parts` - Ehtiyot qismlar

### Users

- `GET /api/users/me` - Profil
- `PUT /api/users/me` - Profilni yangilash
- `PUT /api/users/me/location` - Location yangilash

## 🔐 Authentication

Barcha himoyalangan endpointlar uchun header qo'shish kerak:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

## 🧪 Test qilish

```bash
# Health check
curl http://localhost:3000/health

# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998901234567",
    "password": "password123",
    "full_name": "Test User"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998901234567",
    "password": "password123"
  }'
```

## 📊 Database Schema

### Tables

- `users` - Foydalanuvchilar
- `providers` - Xizmat ko'rsatuvchilar
- `orders` - So'rovlar
- `service_areas` - Xizmat hududlari
- `reviews` - Baholar
- `workshops` - Ustaxonalar
- `parts` - Ehtiyot qismlar
- `notifications` - Bildirishnomalar

### PostGIS

Geo ma'lumotlar uchun PostGIS ishlatiladi:
- `GEOMETRY(Point, 4326)` - lat/lon koordinatalar
- `ST_Distance()` - Masofa hisoblash
- `ST_DWithin()` - Radiusda qidirish

## 🔌 WebSocket Events

### Client → Server

- `provider:location` - Provider location update
- `join:order` - Order room'ga qo'shilish
- `leave:order` - Order room'dan chiqish

### Server → Client

- `new_order` - Yangi so'rov
- `order:accepted` - So'rov qabul qilindi
- `order:status_changed` - Status o'zgardi
- `order:completed` - Xizmat yakunlandi
- `provider:location:update` - Provider joylashuvi yangilandi

## 🛠️ Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL + PostGIS
- **WebSocket:** Socket.IO
- **Auth:** JWT (jsonwebtoken)
- **Password:** bcrypt
- **Environment:** dotenv

## 📝 Demo Users

Test uchun demo foydalanuvchilar (parol: `password123`):

- `+998901234567` - Ali Valiyev (client)
- `+998902345678` - Bobur Usmonov (provider - mechanic)
- `+998904567890` - Eldor Toshmatov (provider - fuel delivery)
- `+998905678901` - Farida Ahmedova (provider - tow truck)

## 🐛 Debug

```bash
# Loglarni ko'rish
npm run dev

# Database connection test
psql -U postgres -d avtoassist -c "SELECT NOW();"

# PostGIS extension test
psql -U postgres -d avtoassist -c "SELECT PostGIS_Version();"
```

## 📦 Project Structure

```
backend/
├── config/
│   ├── database.js      # PostgreSQL connection
│   └── jwt.js           # JWT helpers
├── controllers/
│   ├── authController.js
│   ├── orderController.js
│   ├── providerController.js
│   └── userController.js
├── middleware/
│   ├── auth.js          # JWT authentication
│   └── errorHandler.js  # Error handling
├── migrations/
│   ├── 001_create_tables.sql
│   ├── 002_seed_data.sql
│   └── run.js
├── routes/
│   ├── auth.js
│   ├── orders.js
│   ├── providers.js
│   └── users.js
├── .env.example
├── .gitignore
├── package.json
├── README.md
└── server.js            # Main entry point
```
