# 🚀 AvtoAssist - Ishga Tushirish Yo'riqnomasi

## 📋 Talab qilinadigan dasturlar

### Backend uchun:
- ✅ Node.js (v18 yoki yuqori) - [nodejs.org](https://nodejs.org)
- ✅ PostgreSQL (v14 yoki yuqori) - [postgresql.org](https://www.postgresql.org/download/)
- ✅ Git

### Mobile uchun:
- ✅ Flutter SDK (v3.0+) - [docs.flutter.dev](https://docs.flutter.dev/get-started/install)
- ✅ Android Studio (Android uchun)
- ✅ Xcode (iOS uchun, faqat Mac)

---

## 🎯 Variantlar

### **Variant 1: To'liq ishga tushirish (tavsiya)**
Backend server + Flutter mobil ilova birga

### **Variant 2: Faqat frontend demo**
Backend'siz, demo ma'lumotlar bilan

---

## 📱 VARIANT 1: To'liq Ishga Tushirish

### QADAM 1: Repositoriyani yuklab olish

```bash
# Terminal ochib quyidagi buyruqni yozing:
git clone https://github.com/EshtoshevShohjahon/Clauder.git
cd Clauder/avtoassist
```

---

### QADAM 2: Backend Serverni Ishga Tushirish

#### 2.1. PostgreSQL Database yaratish

PostgreSQL ni ishga tushiring, so'ng terminal'da:

```bash
# PostgreSQL ga kirish (Windows)
psql -U postgres

# PostgreSQL ga kirish (Mac/Linux)
sudo -u postgres psql
```

PostgreSQL ichida quyidagi buyruqlarni bajaring:

```sql
-- Database yaratish
CREATE DATABASE avtoassist;

-- Database'ga kirish
\c avtoassist

-- PostGIS extension qo'shish (geo ma'lumotlar uchun)
CREATE EXTENSION postgis;

-- Chiqish
\q
```

#### 2.2. Backend Dependencies o'rnatish

```bash
# Backend papkaga o'tish
cd backend

# Node.js paketlarini o'rnatish
npm install
```

#### 2.3. Environment sozlash

```bash
# .env faylini yaratish
cp .env.example .env

# .env faylini tahrirlash
nano .env  # yoki notepad .env (Windows)
```

`.env` fayli ichida:

```env
PORT=3000
NODE_ENV=development

# PostgreSQL sozlamalari
DB_HOST=localhost
DB_PORT=5432
DB_NAME=avtoassist
DB_USER=postgres
DB_PASSWORD=your_password_here  # <-- O'z parolingizni kiriting

JWT_SECRET=my_secret_key_12345
JWT_EXPIRES_IN=7d
```

**MUHIM:** `DB_PASSWORD` o'rniga o'z PostgreSQL parolingizni kiriting!

#### 2.4. Database Migration (jadvallar yaratish)

```bash
# Barcha jadvallarni va demo ma'lumotlarni yaratish
npm run migrate
```

Ko'rinishi:
```
🔄 Migratsiyalar boshlanmoqda...
⚙️  Ishga tushirilmoqda: 001_create_tables.sql
✓ Bajarildi: 001_create_tables.sql
⚙️  Ishga tushirilmoqda: 002_seed_data.sql
✓ Bajarildi: 002_seed_data.sql
✅ Barcha migratsiyalar muvaffaqiyatli bajarildi!
```

#### 2.5. Serverni ishga tushirish

```bash
# Development mode (auto-restart)
npm run dev
```

✅ **Muvaffaqiyatli!** Agar quyidagi xabarni ko'rsangiz:

```
=================================
🚀 Server ishga tushdi: http://localhost:3000
📡 WebSocket: ws://localhost:3000
🌍 Environment: development
=================================
✓ Database connected
```

Server tayyor! Brauzerda tekshiring: http://localhost:3000/health

---

### QADAM 3: Flutter Mobil Ilovani Ishga Tushirish

#### 3.1. Flutter SDK tekshirish

Yangi terminal oching va tekshiring:

```bash
flutter --version
flutter doctor
```

Agar Flutter o'rnatilmagan bo'lsa: https://docs.flutter.dev/get-started/install

#### 3.2. Dependencies o'rnatish

```bash
# Avtoassist papkasida
cd mobile

# Flutter paketlarini o'rnatish
flutter pub get
```

#### 3.3. Emulator/Simulator ishga tushirish

**Android:**
```bash
# Android emulyatorlarni ko'rish
flutter emulators

# Emulator ishga tushirish
flutter emulators --launch <emulator_id>
```

**iOS (faqat Mac):**
```bash
# iOS simulator ochish
open -a Simulator
```

**Yoki:** Android Studio > Tools > AVD Manager > Create Virtual Device

#### 3.4. Ilovani ishga tushirish

```bash
# Ilovani ishga tushirish
flutter run
```

Bir necha soniyadan keyin ilova emulyatorda ochiladi! 🎉

---

## 🧪 VARIANT 2: Faqat Frontend Demo

Agar backend o'rnatmasdan faqat UI ko'rmoqchi bo'lsangiz:

### Qadam 1: Repositoriyani yuklab olish

```bash
git clone https://github.com/EshtoshevShohjahon/Clauder.git
cd Clauder/avtoassist/mobile
```

### Qadam 2: Demo rejimga o'zgartirish

`lib/utils/constants.dart` faylini oching va o'zgartiring:

```dart
// Demo mode - backend'siz ishlaydi
static const bool isDemoMode = true;  // <-- true ga o'zgartiring
```

### Qadam 3: Dependencies va ishga tushirish

```bash
flutter pub get
flutter run
```

Demo rejimda ilova static ma'lumotlar bilan ishlaydi.

---

## 📱 Ilovani Sinash

### Test Userlar (Backend bilan)

Backend migration demo userlar yaratadi. Login qilish uchun:

| Telefon | Parol | Rol |
|---------|-------|-----|
| +998901234567 | password123 | Client (Mijoz) |
| +998902345678 | password123 | Provider (Usta - texnik yordam) |
| +998904567890 | password123 | Provider (Yoqilg'i quyish) |

### Sinash Ketma-ketligi:

#### Client (Mijoz) sifatida:

1. **Login:** +998901234567 / password123
2. **Bosh sahifa:** 6 ta xizmat kartasini ko'ring
3. **"Texnik yordam"** ni tanlang
4. **So'rov yuborish:** Muammo tavsifini yozing
5. **"Avtomobil" tab:** Chevrolet Gentra ko'rinadi
6. **Moy almashtirish tarixi:** 3 ta tarix yozuvi
7. **Eslatma:** "Moy almashtirish vaqti - 500 km qoldi"

#### Provider (Xizmat ko'rsatuvchi) sifatida:

1. **Login:** +998902345678 / password123
2. **Provider bosh sahifa:** Online/Offline toggle
3. **Statistika:** Bugun 5 ta so'rov, jami 156
4. **Reyting:** 4.7 ⭐
5. **Yangi so'rovlar:** Kelganida xabarnoma

---

## 🐛 Muammolarni Hal Qilish

### Backend xatolari:

**"ECONNREFUSED" yoki database error:**
```bash
# PostgreSQL ishga tushirish
# Windows:
pg_ctl -D "C:\Program Files\PostgreSQL\14\data" start

# Mac/Linux:
sudo service postgresql start
```

**"cannot find module" error:**
```bash
cd backend
rm -rf node_modules
npm install
```

### Flutter xatolari:

**"Waiting for another flutter command to release the startup lock":**
```bash
rm -rf ~/.dart_tool/
flutter clean
flutter pub get
```

**"No devices found":**
```bash
# Android emulator ishga tushirish
flutter emulators --launch Pixel_5_API_31

# Yoki Android Studio'dan qurilma tanlang
```

**"CocoaPods not installed" (Mac/iOS):**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

---

## 📊 API Endpointlarini Test Qilish

Backend ishga tushgandan keyin:

### Curl bilan test:

```bash
# Health check
curl http://localhost:3000/health

# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998909999999",
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

### Postman bilan test:

1. Postman ochish
2. New Collection: AvtoAssist API
3. Import: backend/README.md dan endpointlar
4. Token olish: POST /api/auth/login
5. Headers ga qo'shish: `Authorization: Bearer YOUR_TOKEN`

---

## 🎨 Ekranlarni Ko'rish

Ilovani o'rnatmasdan dizaynni ko'rish uchun:

1. GitHub'dan `EKRANLAR_MOCKUP.html` ni yuklab oling
2. Brauzerda oching
3. 7 ta ekranni interaktiv ko'ring

Yoki to'g'ridan GitHub'da ko'ring: [Interaktiv Mockup](https://github.com/EshtoshevShohjahon/Clauder/blob/main/EKRANLAR_MOCKUP.html)

---

## 📱 Android APK Yaratish

Release APK yaratish uchun:

```bash
cd mobile

# APK build qilish
flutter build apk --release

# Natija:
# build/app/outputs/flutter-apk/app-release.apk
```

APK faylini telefoningizga ko'chirib o'rnating.

---

## 🔥 Production Deploy

### Backend (Server):

**Heroku:**
```bash
heroku create avtoassist-api
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
```

**DigitalOcean:**
- Create Droplet (Ubuntu 22.04)
- Install Node.js, PostgreSQL, Nginx
- Deploy backend code
- SSL sertifikat (Let's Encrypt)

### Mobile:

**Google Play Store:**
```bash
flutter build appbundle --release
# Upload to Play Console
```

**Apple App Store:**
```bash
flutter build ios --release
# Upload via Xcode
```

---

## 📞 Yordam

Muammo bo'lsa:

- 📧 Email: support@avtoassist.uz
- 💬 GitHub Issues: https://github.com/EshtoshevShohjahon/Clauder/issues
- 📚 Flutter Docs: https://docs.flutter.dev
- 📚 Node.js Docs: https://nodejs.org/docs

---

## ✅ To'liq Checklist

Backend:
- [ ] PostgreSQL o'rnatildi
- [ ] Database yaratildi
- [ ] npm install bajarildi
- [ ] .env fayli to'ldirildi
- [ ] Migration bajarildi
- [ ] Server http://localhost:3000 da ishlamoqda

Flutter:
- [ ] Flutter SDK o'rnatildi
- [ ] Emulator/Simulator ishlamoqda
- [ ] flutter pub get bajarildi
- [ ] Ilova emulator'da ochildi

Test:
- [ ] Login qila oldim
- [ ] Xizmatlarni ko'rdim
- [ ] So'rov yarata oldim
- [ ] Avtomobil bo'limini ko'rdim
- [ ] Moy almashtirish qo'sha oldim

---

**Omad!** 🎉 Savollar bo'lsa, bemalol so'rang!
