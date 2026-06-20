# 🚗 AvtoAssist - Avtomobil Xizmatlari Platformasi

Yandex Taxi modelidagi mobil ilova - texnik yordam, yoqilg'i quyish, avtoyuv, evakuator va boshqa avto xizmatlarini bir joyda birlashtirgan platforma.

## 📱 Loyiha Tuzilmasi

```
avtoassist/
├── backend/          # Node.js + Express + PostgreSQL server
├── mobile/           # Flutter mobil ilova (iOS & Android)
└── README.md         # Ushbu fayl
```

## 🎯 Xizmatlar

| Xizmat | Tavsif |
|--------|--------|
| 🔧 **Texnik yordam** | Usta joyga boradi, avtomobilni ta'mirlaydi |
| ⛽ **Yoqilg'i quyish** | Xizmat borib, yoqilg'i quyib beradi |
| 🚿 **Avtomobil yuvish** | Xizmat borib yuviadi yoki yaqin moyka ko'rsatadi |
| 🏪 **Ehtiyot qismlar** | Xaritada do'konlar, narx va mavjudlik |
| 🏭 **Ustaxonalar** | Xaritada servislar, reyting, narx |
| 🚚 **Evakuator** | Avtomobilni ko'tarib olib ketish |

## 🛠️ Texnologiyalar

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL + PostGIS (geo ma'lumotlar)
- **WebSocket:** Socket.IO (real-time kuzatuv)
- **Auth:** JWT + bcrypt

### Mobile
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **HTTP:** Dio / http package
- **Maps:** Google Maps Flutter
- **WebSocket:** socket_io_client

## 🚀 Ishga Tushirish

### Backend Serverni Ishga Tushirish

```bash
# Backend papkaga o'tish
cd backend

# Dependencies o'rnatish
npm install

# PostgreSQL database yaratish
psql -U postgres
CREATE DATABASE avtoassist;
CREATE EXTENSION postgis;
\q

# Environment o'rnatish
cp .env.example .env
nano .env  # Database parolini kiriting

# Database migration
npm run migrate

# Serverni ishga tushirish
npm run dev
```

Server ishga tushadi: http://localhost:3000

### Flutter Ilovani Ishga Tushirish

```bash
# Mobile papkaga o'tish
cd mobile

# Dependencies o'rnatish
flutter pub get

# Android emulator yoki iOS simulator ishga tushirish
flutter emulators --launch <emulator_id>

# Ilovani ishga tushirish
flutter run

# Yoki release build
flutter build apk  # Android
flutter build ios  # iOS
```

## 📊 Database Schema

### Jadvallar

1. **users** - Foydalanuvchilar (client va provider)
2. **providers** - Xizmat ko'rsatuvchilar
3. **orders** - So'rovlar (xizmat buyurtmalari)
4. **service_areas** - Xizmat hududlari
5. **reviews** - Baholar va fikrlar
6. **workshops** - Ustaxonalar
7. **parts** - Ehtiyot qismlar
8. **notifications** - Bildirishnomalar

### PostGIS (Geo Ma'lumotlar)

Database geografik ma'lumotlarni saqlash uchun PostGIS extensiondan foydalanadi:

- `GEOMETRY(Point, 4326)` - lat/lon koordinatalar
- `ST_Distance()` - Masofa hisoblash
- `ST_DWithin()` - Radius ichida qidirish

## 📡 API Endpoints

### Authentication

```
POST /api/auth/register       - Ro'yxatdan o'tish
POST /api/auth/login          - Kirish
POST /api/auth/verify-phone   - Telefon tasdiqlash
POST /api/auth/select-role    - Rol tanlash (client/provider)
```

### Orders

```
POST   /api/orders            - Yangi so'rov yaratish
GET    /api/orders            - So'rovlar ro'yxati
GET    /api/orders/:id        - Bitta so'rov
POST   /api/orders/:id/accept - Qabul qilish (provider)
PUT    /api/orders/:id/status - Status o'zgartirish
POST   /api/orders/:id/complete - Yakunlash
POST   /api/orders/:id/cancel - Bekor qilish
POST   /api/orders/:id/rate   - Baho berish
```

### Providers

```
GET /api/providers         - Providerlar ro'yxati
GET /api/providers/nearby  - Yaqin atrofdagi providerlar
GET /api/providers/:id     - Provider ma'lumotlari
GET /api/providers/workshops - Ustaxonalar
GET /api/providers/parts   - Ehtiyot qismlar
```

### Users

```
GET /api/users/me          - Profil
PUT /api/users/me          - Profilni yangilash
PUT /api/users/me/location - Location yangilash
```

## 🔐 Authentication

API so'rovlari uchun JWT token headerga qo'shiladi:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

## 🌐 WebSocket Events

### Client → Server

- `provider:location` - Provider location update
- `join:order` - Order room'ga qo'shilish
- `leave:order` - Order room'dan chiqish

### Server → Client

- `new_order` - Yangi so'rov
- `order:accepted` - So'rov qabul qilindi
- `order:status_changed` - Status o'zgardi
- `order:completed` - Xizmat yakunlandi
- `provider:location:update` - Provider joylashuvi

## 📱 Flutter Ekranlar

### Authentication
- **Splash Screen** - Yuklanish ekrani
- **Login Screen** - Kirish
- **Register Screen** - Ro'yxatdan o'tish
- **Role Selection** - Client yoki Provider tanlash

### Client (Mijoz)
- **Home** - Bosh sahifa (6 ta xizmat kartasi)
- **Order Form** - So'rov yaratish
- **Order Tracking** - Kuzatuv (real-time map)
- **Orders List** - So'rovlar tarixi
- **Parts Catalog** - Ehtiyot qismlar
- **Workshops List** - Ustaxonalar

### Provider (Xizmat ko'rsatuvchi)
- **Provider Home** - Online/Offline status
- **Incoming Requests** - Yangi so'rovlar
- **Active Orders** - Faol buyurtmalar
- **Navigation** - Mijozga yo'l ko'rsatish

### Common
- **Profile** - Profil
- **Settings** - Sozlamalar
- **Notifications** - Bildirishnomalar

## 🧪 Test Qilish

### Backend Test

```bash
# Server health check
curl http://localhost:3000/health

# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone": "+998901234567", "password": "password123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+998901234567", "password": "password123"}'
```

### Demo Userlar

Backend migration'da demo userlar yaratiladi (parol: `password123`):

- `+998901234567` - Ali Valiyev (client)
- `+998902345678` - Bobur Usmonov (provider - mechanic)
- `+998904567890` - Eldor Toshmatov (provider - fuel delivery)
- `+998905678901` - Farida Ahmedova (provider - tow truck)

## 📦 Dependencies

### Backend (Node.js)

```json
{
  "express": "^4.18.2",
  "pg": "^8.11.3",
  "bcrypt": "^5.1.1",
  "jsonwebtoken": "^9.0.2",
  "socket.io": "^4.6.2",
  "cors": "^2.8.5",
  "dotenv": "^16.3.1"
}
```

### Flutter

```yaml
dependencies:
  provider: ^6.1.1
  dio: ^5.4.0
  google_maps_flutter: ^2.5.3
  socket_io_client: ^2.0.3+1
  shared_preferences: ^2.2.2
  geolocator: ^10.1.0
```

## 🔧 Konfiguratsiya

### Backend .env

```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=avtoassist
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_secret_key
```

### Flutter constants.dart

```dart
static const String baseUrl = 'http://localhost:3000/api';
static const String wsUrl = 'ws://localhost:3000';
```

Production uchun:
```dart
static const String baseUrl = 'https://api.avtoassist.uz/api';
static const String wsUrl = 'wss://api.avtoassist.uz';
```

## 🚀 Production Deploy

### Backend

1. **Server:** AWS EC2, DigitalOcean, Heroku
2. **Database:** Managed PostgreSQL (AWS RDS, DigitalOcean)
3. **Domain:** SSL sertifikat (Let's Encrypt)
4. **Environment:** NODE_ENV=production

### Mobile

1. **Android:** Google Play Store
2. **iOS:** Apple App Store
3. **API URL:** Production server URLga o'zgartirish

## 📄 Litsenziya

MIT License

## 👨‍💻 Muallif

AvtoAssist - 2024

---

**Savollar yoki yordam kerakmi?** Issue oching yoki email yuboring.
