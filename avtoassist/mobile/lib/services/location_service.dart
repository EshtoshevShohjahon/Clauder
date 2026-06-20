import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// GPS Location Service
/// 
/// MUHIM: Bu servis 100% OFFLINE ishlaydi!
/// GPS sun'iy yo'ldosh (satellite) signallaridan foydalanadi.
/// Internet aloqasi KERAK EMAS!
/// 
/// Qanday ishlaydi:
/// 1. Telefon GPS antennasi orqali satellite'lardan signal oladi
/// 2. Kamida 4 ta satellite kerak aniq joylashuv uchun
/// 3. Binolar ichida signal zaif, ochiq joyda kuchli
/// 4. Birinchi marta 30-60 soniya vaqt olishi mumkin
/// 5. Keyingi safar 5-10 soniyada topadi
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;
  static const String _lastPositionKey = 'last_known_position';

  /// GPS aniqlik darajasi (metrda)
  /// Ochiq joyda: 5-10 metr
  /// Binolar orasida: 20-30 metr
  /// Binolar ichida: 50+ metr (yoki ishlamaydi)
  static const double minAccuracy = 50.0;

  /// Check if location services are enabled
  /// Internet yo'q bo'lsa ham ishlaydi - GPS hardware tekshiriladi
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Joriy joylashuvni olish (OFFLINE)
  /// 
  /// Bu funksiya FAQAT GPS satellite'lardan foydalanadi!
  /// Internet kerak emas!
  /// 
  /// Parametrlar:
  /// - accuracy: HIGH = aniqroq, lekin sekinroq (30-60s)
  ///            MEDIUM = o'rtacha (10-20s)
  ///            LOW = tez, lekin noaniq (5-10s)
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // GPS yoqilganmi?
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS o\'chirilgan. Sozlamalardan yoqing.');
      }

      // Ruxsat bormi?
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('GPS uchun ruxsat berilmagan');
      }

      // Joylashuvni olish - SATELLITE'DAN!
      // Internet yo'q bo'lsa ham ishlaydi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: const Duration(seconds: 30),
        // Bu parametr internet ishlatmaydi!
        forceAndroidLocationManager: true, // Android native GPS
      );

      _lastKnownPosition = position;
      await _saveLastPosition(position);
      
      return position;
    } catch (e) {
      // Agar yangi position ololmasak, oxirgi ma'lum position qaytaramiz
      return _lastKnownPosition ?? await _loadLastPosition();
    }
  }

  /// Joylashuv o'zgarishlarini tinglash (real-time)
  /// Internet KERAK EMAS - faqat GPS!
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // metrda
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: const Duration(seconds: 30),
      ),
    );
  }

  /// Oxirgi ma'lum joylashuvni olish (agar GPS ishlamasa)
  Future<Position?> getLastKnownPosition() async {
    try {
      // Telefon xotirasidan oxirgi GPS ma'lumotini olish
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastKnownPosition = position;
        return position;
      }
      
      // Agar telefon xotirasida bo'lmasa, o'zimizning cache'dan olamiz
      return await _loadLastPosition();
    } catch (e) {
      return await _loadLastPosition();
    }
  }

  /// Ikki nuqta orasidagi masofani hisoblash (metrda)
  /// Internet kerak emas - matematik hisob
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Masofani formatlash
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Position'dan LatLng'ga o'tkazish
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  /// Oxirgi joylashuvni saqlash
  Future<void> _saveLastPosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp.toIso8601String(),
      };
      await prefs.setString(_lastPositionKey, jsonEncode(positionData));
    } catch (e) {
      // Ignore errors
    }
  }

  /// Oxirgi joylashuvni yuklash
  Future<Position?> _loadLastPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionString = prefs.getString(_lastPositionKey);
      
      if (positionString != null) {
        final positionData = jsonDecode(positionString) as Map<String, dynamic>;
        
        _lastKnownPosition = Position(
          latitude: positionData['latitude'],
          longitude: positionData['longitude'],
          accuracy: positionData['accuracy'],
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: DateTime.parse(positionData['timestamp']),
        );
        
        return _lastKnownPosition;
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  /// GPS sozlamalarini ochish
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
