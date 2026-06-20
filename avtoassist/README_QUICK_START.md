# 🚀 AvtoAssist - Tezkor Ishga Tushirish

Ushbu skriptlar **avtomatik ravishda** hamma narsani sozlaydi va ishga tushiradi!

---

## 📦 Talab qilinadigan dasturlar

Oldin quyidagilarni o'rnating:

- **Node.js** (v18+): https://nodejs.org
- **PostgreSQL** (v14+): https://www.postgresql.org/download/
- **Flutter** (ixtiyoriy, mobile uchun): https://docs.flutter.dev

---

## ⚡ 1-BOSQICH: Avtomatik Setup

**Bitta buyruq bilan hamma narsani sozlaydi:**
- PostgreSQL database yaratadi
- Backend ni sozlaydi
- Migration bajaradi (demo ma'lumotlar)
- Flutter ni sozlaydi

```bash
cd avtoassist
./setup.sh
```

**Script sizdan so'raydi:**
1. PostgreSQL foydalanuvchi nomi (default: `postgres`)
2. PostgreSQL parol

**Natija:**
✅ Database yaratildi  
✅ Backend sozlandi  
✅ Migration bajarildi  
✅ Demo userlar qo'shildi  
✅ Flutter tayyor  

---

## 🚀 2-BOSQICH: Ishga Tushirish

Backend va Flutter ilovani **bir vaqtning o'zida** ishga tushiradi:

```bash
./start.sh
```

**Natija:**
- Backend: http://localhost:3000 ✅
- Flutter: Emulatorda ochiladi ✅

**To'xtatish:** `Ctrl+C`

---

## 🧪 3-BOSQICH: Test Qilish

Backend API'ni **avtomatik test qiladi** (10 ta test):

```bash
./test.sh
```

**Testlar:**

1. ✅ Health check
2. ✅ Ro'yxatdan o'tish
3. ✅ Kirish (login)
4. ✅ Profil olish
5. ✅ So'rovlar ro'yxati
6. ✅ Providerlar ro'yxati
7. ✅ Avtomobillar
8. ✅ Avtomobil qo'shish
9. ✅ Moy almashtirish qo'shish
10. ✅ Moy tarixi

---

## 📱 4-BOSQICH: Android APK Yaratish

Release APK build qiladi (telefoniga o'rnatish uchun):

```bash
./build-apk.sh
```

**Natija:**
- APK: `avtoassist-release.apk`
- Hajmi: ~40-50 MB

**O'rnatish:**
1. APK ni telefoniga yuborish (USB, Telegram...)
2. Faylni ochish
3. "Install" ni bosish

---

## 🔑 Demo Userlar

Backend migration avtomatik yaratadi:

| Telefon | Parol | Rol | Tavsif |
|---------|-------|-----|--------|
| +998901234567 | password123 | Client | Mijoz |
| +998902345678 | password123 | Provider | Usta (texnik yordam) |
| +998904567890 | password123 | Provider | Yoqilg'i quyish |
| +998905678901 | password123 | Provider | Evakuator |

---

## 📊 Fayllar

| Fayl | Vazifasi |
|------|----------|
| `setup.sh` | Bir marta setup |
| `start.sh` | Ishga tushirish |
| `test.sh` | API test qilish |
| `build-apk.sh` | Android APK yaratish |

---

## 🐛 Muammo bo'lsa?

### PostgreSQL ishlamayapti

```bash
# Mac/Linux
sudo service postgresql start

# Windows
pg_ctl -D "C:\Program Files\PostgreSQL\14\data" start
```

### Port band (3000)

Backend `.env` faylida `PORT=3000` ni o'zgartiring.

### Flutter qurilma yo'q

```bash
# Emulyatorlarni ko'rish
flutter emulators

# Emulator ishga tushirish
flutter emulators --launch Pixel_5_API_31
```

---

## ✅ To'liq Checklist

**Setup:**
- [ ] `./setup.sh` ishga tushirildi
- [ ] PostgreSQL parol kiritildi
- [ ] Database yaratildi
- [ ] Migration bajarildi

**Ishga tushirish:**
- [ ] `./start.sh` ishga tushirildi
- [ ] Backend http://localhost:3000 da ishlayapti
- [ ] Flutter emulatorda ochildi

**Test:**
- [ ] `./test.sh` barcha testlardan o'tdi
- [ ] Login qila oldim (+998901234567)
- [ ] So'rovlar ko'rinmoqda
- [ ] Avtomobil qo'sha oldim

---

## 🎯 Qisqa Yo'l (3 buyruq)

```bash
# 1. Setup
./setup.sh

# 2. Ishga tushirish
./start.sh

# 3. Test qilish (boshqa terminal)
./test.sh
```

**Hammasi tayyor!** 🎉

---

## 📞 Yordam

Muammo bo'lsa:
- **To'liq yo'riqnoma:** `ISHGA_TUSHIRISH.md`
- **Backend docs:** `backend/README.md`
- **GitHub Issues:** https://github.com/EshtoshevShohjahon/Clauder/issues
