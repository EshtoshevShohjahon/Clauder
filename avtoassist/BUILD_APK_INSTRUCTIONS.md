# 📦 AvtoHelp - APK Yaratish Yo'riqnomasi

## 🎯 3 ta Variant

### **Variant 1: O'zingiz kompyuterda (tavsiya)** ⚡

**Eng tez va oson yo'l - bitta buyruq:**

```bash
git clone https://github.com/EshtoshevShohjahon/Clauder.git
cd Clauder/avtoassist
./build-apk.sh
```

**Talablar:**
- Flutter SDK 3.0+
- Android SDK yoki Android Studio

**Natija:** `avtoassist-release.apk` (5-10 daqiqa)

---

### **Variant 2: GitHub Actions (avtomatik)** 🤖

**GitHub'ning o'zida avtomatik build qiladi - hech narsa o'rnatish shart emas!**

#### Qanday ishlaydi:

1. **GitHub repo'ga boring:** https://github.com/EshtoshevShohjahon/Clauder

2. **Actions tab'ni oching**

3. **"Build Android APK" workflow'ni bosing**

4. **"Run workflow" → "Run workflow" tugmasini bosing**

5. **5-10 daqiqa kuting** - avtomatik build bo'ladi

6. **"Artifacts" bo'limidan APK yuklab oling**

**Yoki:** Har commit'da avtomatik build bo'ladi (mobile fayllar o'zgarganda)

---

### **Variant 3: Qo'lda Flutter bilan** 🛠️

**Flutter SDK bor bo'lsa:**

```bash
# 1. Repo yuklab olish
git clone https://github.com/EshtoshevShohjahon/Clauder.git
cd Clauder/avtoassist/mobile

# 2. Dependencies o'rnatish
flutter pub get

# 3. APK build qilish (release)
flutter build apk --release

# 4. APK joylashuvi
# build/app/outputs/flutter-apk/app-release.apk
```

**Advanced (split APKs - kichikroq hajm):**
```bash
flutter build apk --split-per-abi --release
```

Bu 3 ta APK yaratadi (har bir CPU arxitekturasi uchun):
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit) ← ko'pchilik telefonlar
- `app-x86_64-release.apk` (x86 64-bit)

---

## 📱 APK Ma'lumotlari

```
App Name:       AvtoHelp
Package:        uz.avtohelp.app
Version:        1.0.0 (Build 1)
Min Android:    5.0 (API 21) - 99% qurilmalar
Target:         Android 14 (API 34)
Size:           ~40-50 MB (optimized)
Architecture:   ARM, ARM64, x86_64
```

---

## 🔧 Talablar (Variant 1 va 3 uchun)

### **Flutter SDK o'rnatish:**

#### Windows:
1. https://docs.flutter.dev/get-started/install/windows dan yuklab oling
2. ZIP faylni ochib, `C:\flutter` ga qo'ying
3. PATH'ga qo'shing: `C:\flutter\bin`
4. Terminal'da: `flutter doctor`

#### Mac:
```bash
brew install flutter
flutter doctor
```

#### Linux:
```bash
snap install flutter --classic
flutter doctor
```

### **Android SDK (ixtiyoriy):**

Flutter SDK Android SDK ni avtomatik yuklab oladi, lekin Android Studio'ni o'rnatish tavsiya etiladi:
- https://developer.android.com/studio

---

## ⚡ Tezkor Yo'l (10 daqiqa)

**Agar Flutter o'rnatilgan bo'lsa:**

```bash
# 1. Yuklab olish
git clone https://github.com/EshtoshevShohjahon/Clauder.git

# 2. APK yaratish
cd Clauder/avtoassist
./build-apk.sh

# 3. APK tayyor!
# avtoassist-release.apk
```

---

## 📊 Build Vaqti

| Variant | Vaqt | Talablar |
|---------|------|----------|
| `./build-apk.sh` | 5-10 min | Flutter SDK |
| GitHub Actions | 5-10 min | Faqat GitHub account |
| Manual Flutter | 5-10 min | Flutter SDK |

---

## 🐛 Muammolar

### **"Flutter not found"**
```bash
# Flutter o'rnatish
https://docs.flutter.dev/get-started/install

# PATH tekshirish
echo $PATH  # (Mac/Linux)
echo %PATH%  # (Windows)
```

### **"Android SDK not found"**
```bash
# Flutter SDK avtomatik Android SDK yuklab oladi
flutter doctor --android-licenses
```

### **"Build failed"**
```bash
# Clean va retry
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

### **"Java version mismatch"**
```bash
# Java 11 yoki 17 kerak
java -version

# Android Studio'dan Java ishlatish
export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/Contents/Home
```

---

## 📦 APK Hajmini Kichraytirish

### **Split per ABI (tavsiya):**
```bash
flutter build apk --split-per-abi --release
```

Bu 3 ta kichik APK yaratadi (~15-20 MB har biri) universal APK o'rniga (~45 MB).

### **Obfuscation:**
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

## 🚀 Keyingi Qadamlar

### **APK Signing (Play Store uchun):**

1. **Keystore yaratish:**
```bash
keytool -genkey -v -keystore avtohelp-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias avtohelp
```

2. **key.properties yaratish:**
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=avtohelp
storeFile=<path>/avtohelp-key.jks
```

3. **build.gradle'da signing config:**
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

### **App Bundle (Play Store uchun):**
```bash
flutter build appbundle --release
```

---

## ✅ Checklist

**Before Build:**
- [ ] Flutter o'rnatildi (`flutter doctor`)
- [ ] Repo yuklab olindi
- [ ] Dependencies o'rnatildi (`flutter pub get`)

**Build:**
- [ ] APK build qilindi (`flutter build apk --release`)
- [ ] APK topildi (`build/app/outputs/flutter-apk/`)
- [ ] APK hajmi ~40-50 MB

**Test:**
- [ ] APK telefonga yuborildi
- [ ] O'rnatildi (Unknown sources ruxsat berildi)
- [ ] Ilova ochildi va ishladi

---

## 🎊 GitHub Actions Workflow

Men sizga **avtomatik GitHub Actions workflow** tayyorladim!

**Joylashuv:** `.github/workflows/build-apk.yml`

**Qanday ishlaydi:**
1. Har safar `mobile/` papkadagi fayllar o'zgarganda
2. Yoki qo'lda "Run workflow" bosilganda
3. GitHub'ning serverida avtomatik:
   - Flutter o'rnatadi
   - Dependencies yuklab oladi  
   - APK build qiladi
   - Artifacts'ga yuklaydi
   - Release yaratadi

**APK yuklab olish:**
1. GitHub repo → Actions tab
2. Oxirgi successful workflow
3. Artifacts → `avtohelp-apk` ni yuklab olish

---

## 📞 Yordam

Muammo bo'lsa:
- **To'liq yo'riqnoma:** `ISHGA_TUSHIRISH.md`
- **Flutter docs:** https://docs.flutter.dev
- **GitHub Issues:** https://github.com/EshtoshevShohjahon/Clauder/issues

---

**Omad!** APK yaratish muvaffaqiyatli bo'lsin! 🚀
