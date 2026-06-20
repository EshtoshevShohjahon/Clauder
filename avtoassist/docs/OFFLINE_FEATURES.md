# AvtoHelp - Offline Funksiyalar

> Bu hujjat AvtoHelp ilovasining **internet yo'qligida ham ishlaydigan** funksiyalarini tushuntiradi.

## 📱 Umumiy Ma'lumot

AvtoHelp ilovasi **maksimal darajada offline rejimda ishlaydi**. Bu degani:
- ✅ GPS joylashuvni aniqlash (satellite orqali)
- ✅ Xaritani ko'rish va navigatsiya
- ✅ Xizmat ko'rsatuvchilar ma'lumotlari
- ✅ Telefon qilish
- ❌ Yangi buyurtma berish (server bilan bog'lanish kerak)
- ❌ Ro'yxatdan o'tish / Kirish (bir martalik internet kerak)

---

## 🗺️ 1. Offline Xarita

### Qanday ishlaydi?

AvtoHelp **Google Maps** o'rniga **OpenStreetMap** ishlatadi. Bu xaritalar:
- Birinchi marta ochilganda **internetdan yuklanadi**
- Keyin **90 kun davomida** qurilmada saqlanadi
- Internet yo'q bo'lsa, saqlangan xaritadan foydalaniladi

### Texnik detallari:

```
Xarita provideri: OpenStreetMap (OSM)
Cache davri: 90 kun
Cache hajmi: ~50-100 MB (Toshkent shahri uchun)
Tile provider: cached_network_image
Paket: flutter_map ^6.1.0
```

### Foydalanuvchi uchun:

**Offline rejimga tayyorgarlik:**
1. Ilovani ochib, xaritani bir marta ko'ring
2. Kerakli hududlarni zoom qiling (tile'lar yuklanadi)
3. Internet o'chiring - xarita ishlashda davom etadi!

**Eslatma:** Yangi hududlarni ko'rish uchun internet kerak. Lekin ilgari ko'rilgan joylar doim mavjud.

---

## 📍 2. GPS Joylashuv (Offline)

### Qanday ishlaydi?

GPS **sun'iy yo'ldosh (satellite)** signallaridan foydalanadi, **INTERNET KERAK EMAS!**

#### GPS Texnologiyasi:

```
Signal manbai: GPS satellite'lar (24+ orbita)
Aniqlik: 5-10 metr (ochiq joyda)
Internet: Kerak emas ❌
Birinchi topish: 30-60 soniya
Keyingi safar: 5-10 soniya
```

### Foydalanuvchi uchun:

**GPS yaxshi ishlashi uchun:**
- 🌤️ Ochiq joyda bo'ling (osmon ko'rinsin)
- 🏢 Binolar ichida signal zaif
- 🌳 Daraxtlar ostida sekinroq
- 🚗 Mashinada antenna tomi tomonida

**Birinchi marta:**
Telefon 4 ta satellite'dan signal topishi kerak. Bu 30-60 soniya oladi. Sabr qiling!

**Keyingi safar:**
Telefon oxirgi joylashuvni eslaydi, 5-10 soniyada topadi.

### Offline joylashuv xizmati:

```dart
LocationService:
- getCurrentPosition() - Hozirgi GPS
- getLastKnownPosition() - Oxirgi ma'lum joy
- getPositionStream() - Real-time tracking
```

---

## 🏪 3. Xizmat Ko'rsatuvchilar (Offline Cache)

### Qanday ishlaydi?

Barcha do'konlar, yoqilg'i shoxoblari, evakuatorlar ma'lumotlari:
- Birinchi ochilganda **serverdan yuklanadi**
- **SharedPreferences**da saqlanadi
- **7 kun** amal qiladi
- Internet yo'q bo'lsa, cache'dan o'qiladi

### Database:

```sql
service_places jadvali:
- 6 ta Yoqilg'i quyish shoxoblari
- 6 ta Ehtiyot qismlar do'konlari  
- 6 ta Avto ustaxonalar
- 3 ta Avto yuvish
- 2 ta Shinomontaj
- 4 ta Evakuator

Jami: 27+ real Toshkent xizmat ko'rsatuvchilar
```

### Har bir xizmat ko'rsatuvchida:

- ✅ Nomi
- ✅ Manzili
- ✅ Telefon (1-2 ta)
- ✅ GPS koordinatalari
- ✅ Ish vaqti
- ✅ Reyting
- ✅ Tavsif

### Foydalanuvchi uchun:

**Offline rejimga tayyorgarlik:**
1. Asosiy ekrandan xizmatlarni bir marta oching
2. Ma'lumotlar avtomatik cache qilinadi
3. 7 kun ichida internet yo'q bo'lsa ham ishlaydi

**Offline ko'rsatkich:**
Ekran tepasida "Offline rejim" sariq badge ko'rinadi.

---

## 📞 4. Telefon Qilish (Offline)

### Qanday ishlaydi?

Telefon qilish **100% offline**!

```dart
PhoneService:
- makePhoneCall(phone) - To'g'ridan-to'g'ri qo'ng'iroq
- tel:// protokol - Android/iOS native
- Internet kerak emas ❌
```

### Xususiyatlari:

- ✅ Ikki telefon bo'lsa, tanlash dialog
- ✅ O'zbekiston format: +998 XX XXX XX XX
- ✅ Validation va tozalash
- ✅ Xato bo'lsa, friendly xabar

### Foydalanuvchi uchun:

1. Xaritada joyni bosing
2. "Qo'ng'iroq qilish" tugmasi
3. Ikki telefon bo'lsa, tanlang
4. Telefon ilovasi ochiladi

---

## 📊 Cache Boshqaruvi

### Cache Hajmlari:

| Ma'lumot | Hajm | Davr | Joylashuv |
|----------|------|------|-----------|
| Xarita tile'lari | 50-100 MB | 90 kun | Device cache |
| Service places | ~50 KB | 7 kun | SharedPreferences |
| Oxirgi GPS | <1 KB | Abadiy | SharedPreferences |

### Cache Tozalash:

Ilova sozlamalaridan:
- ❌ Xarita cache'ni tozalash
- ❌ Service places cache'ni yangilash
- ❌ Barcha cache'ni tozalash

---

## 🚫 Offline Rejimda Ishlamaydigan Funksiyalar

### Internet kerak:

1. **Ro'yxatdan o'tish / Kirish**
   - Bir martalik internet kerak
   - Token saqlanadi, keyingi safar avtomatik

2. **Yangi buyurtma berish**
   - Server bilan bog'lanish
   - Provider'larga xabar yuborish

3. **Real-time tracking**
   - Provider joylashuvini kuzatish
   - WebSocket kerak

4. **To'lovlar**
   - Online to'lov tizimlari

5. **Yangi xizmat ko'rsatuvchilar**
   - Database'dan so'rovlar

---

## 🔒 Xavfsizlik va Maxfiylik

### GPS Ma'lumotlari:

- ✅ Faqat qurilmada saqlanadi
- ✅ Serverga yuborilmaydi (foydalanuvchi ruxsat bersa, faqat buyurtma vaqtida)
- ✅ Oxirgi joylashuv encrypted

### Cache Ma'lumotlari:

- ✅ SharedPreferences - Encrypted (Android Keystore)
- ✅ Maxfiy ma'lumotlar cache qilinmaydi
- ✅ Token - Secure storage

---

## 🛠️ Ishlab Chiquvchilar Uchun

### Offline Map Service:

```dart
OfflineMapService:
- getTileLayer() - OSM tile provider with cache
- createUserMarker() - User location marker
- createServiceMarker() - Service place marker
- CachedTileProvider - Custom tile caching
```

### Location Service:

```dart
LocationService:
- getCurrentPosition() - GPS satellite
- getLastKnownPosition() - Fallback
- calculateDistance() - Haversine formula
- formatDistance() - User-friendly format
```

### Places Provider:

```dart
PlacesProvider:
- loadPlaces() - Load with cache fallback
- loadNearbyPlaces() - Filter by distance
- _loadFromCache() - SharedPreferences
- _saveToCache() - Automatic caching
```

### Phone Service:

```dart
PhoneService:
- makePhoneCall() - url_launcher tel://
- formatPhoneNumber() - UZ format
- showPhoneCallDialog() - 2 phones selector
```

---

## 📝 FAQ

### Q: GPS ishlamayapti, nima qilish kerak?
**A:** 
1. Sozlamalardan GPS yoqilganini tekshiring
2. Ochiq joyga chiqing (osmon ko'rinsin)
3. 30-60 soniya sabr qiling (birinchi marta)
4. Airplane mode o'chirilganini tekshiring

### Q: Xarita ochilmayapti?
**A:**
1. Birinchi marta internet kerak
2. Cache to'lgan bo'lishi mumkin - tozalang
3. Ilovani qaytadan oching

### Q: Offline rejimda yangi xizmat ko'rsatuvchilar ko'rinmayapti?
**A:** Internet orqali bir marta yangilash kerak. Cache 7 kun amal qiladi.

### Q: Qo'ng'iroq qilganda "Xato" xabari chiqadi?
**A:**
1. Telefon raqami to'g'ri formatda (+998XXXXXXXXX)
2. Telefon ilovasi o'rnatilgan
3. Telefon ruxsati berilgan

### Q: Cache qancha joy egallaydi?
**A:** 
- Xarita: ~50-100 MB
- Service places: ~50 KB
- Jami: ~100 MB

### Q: Cache qachon tozalanadi?
**A:**
- Xarita: 90 kundan keyin avtomatik
- Service places: 7 kundan keyin
- Qo'lda: Sozlamalardan

---

## 🎯 Xulosa

AvtoHelp ilovasi **maksimal offline funksiyalarga** ega:

✅ **GPS** - Satellite orqali, internet kerak emas  
✅ **Xarita** - OpenStreetMap, 90 kun cache  
✅ **Xizmat ko'rsatuvchilar** - 27+ joy, 7 kun cache  
✅ **Telefon qilish** - 100% offline  

❌ **Buyurtmalar** - Internet kerak  
❌ **Ro'yxatdan o'tish** - Bir martalik internet  

**Tavsiya:** Ilk bor ilovani ochib, kerakli hududlarni ko'rib chiqing. Keyin internet yo'q joyda ham ishlatishingiz mumkin!

---

**Versiya:** 1.0.0  
**Oxirgi yangilanish:** 2026-06-20  
**Muallif:** AvtoHelp Development Team
