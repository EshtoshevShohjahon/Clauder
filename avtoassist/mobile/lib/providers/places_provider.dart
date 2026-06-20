import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, asin, pi;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avtoassist/models/service_place_model.dart';
import 'package:avtoassist/services/api_service.dart';

/// Xizmat ko'rsatuvchilar provider
/// 
/// OFFLINE rejimda ishlaydi:
/// - Birinchi marta internet orqali yuklanadi
/// - SharedPreferences'da cache qilinadi
/// - Internet yo'q bo'lsa, cache'dan o'qiladi
class PlacesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<ServicePlace> _places = [];
  bool _isLoading = false;
  String? _error;
  bool _isOfflineMode = false;

  List<ServicePlace> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;

  static const String _cacheKey = 'service_places_cache';
  static const String _cacheTimestampKey = 'service_places_cache_timestamp';
  static const Duration _cacheExpiry = Duration(days: 7);

  /// Barcha xizmat ko'rsatuvchilarni yuklash
  Future<void> loadPlaces({String? type, bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cache'ni tekshirish
      if (!forceRefresh) {
        final cachedPlaces = await _loadFromCache(type);
        if (cachedPlaces != null && cachedPlaces.isNotEmpty) {
          _places = cachedPlaces;
          _isOfflineMode = true;
          _isLoading = false;
          notifyListeners();
          
          // Background'da yangilash
          _refreshInBackground(type);
          return;
        }
      }

      // Internet orqali yuklash
      final response = await _api.get(
        '/places',
        queryParams: type != null ? {'type': type} : null,
        needsAuth: false,
      );

      if (response['success'] == true) {
        final placesData = response['data']['places'] as List;
        _places = placesData.map((json) => ServicePlace.fromJson(json)).toList();
        _isOfflineMode = false;
        
        // Cache'ga saqlash
        await _saveToCache(_places, type);
      }
    } catch (e) {
      _error = e.toString();
      
      // Xatolik bo'lsa, cache'dan o'qish
      final cachedPlaces = await _loadFromCache(type);
      if (cachedPlaces != null && cachedPlaces.isNotEmpty) {
        _places = cachedPlaces;
        _isOfflineMode = true;
        _error = null; // Cache mavjud bo'lsa, xatolikni yo'qotish
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Yaqin atrofdagi xizmat ko'rsatuvchilar
  Future<void> loadNearbyPlaces({
    required double latitude,
    required double longitude,
    String? type,
    double radius = 10000,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(
        '/places/nearby',
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radius.toString(),
          if (type != null) 'type': type,
        },
        needsAuth: false,
      );

      if (response['success'] == true) {
        final placesData = response['data']['places'] as List;
        _places = placesData.map((json) => ServicePlace.fromJson(json)).toList();
        _isOfflineMode = false;
      }
    } catch (e) {
      _error = e.toString();
      
      // Internet yo'q bo'lsa, barcha cache'dan filter qilish
      final allCached = await _loadFromCache(type);
      if (allCached != null) {
        // Masofani hisoblash va yaqinlarini topish (offline)
        _places = _filterByDistance(allCached, latitude, longitude, radius);
        _isOfflineMode = true;
        _error = null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Background'da yangilash (foydalanuvchi ko'rmaydi)
  Future<void> _refreshInBackground(String? type) async {
    try {
      final response = await _api.get(
        '/places',
        queryParams: type != null ? {'type': type} : null,
        needsAuth: false,
      );

      if (response['success'] == true) {
        final placesData = response['data']['places'] as List;
        final newPlaces = placesData.map((json) => ServicePlace.fromJson(json)).toList();
        
        await _saveToCache(newPlaces, type);
        
        // Yangi ma'lumotlar bilan yangilash
        _places = newPlaces;
        _isOfflineMode = false;
        notifyListeners();
      }
    } catch (e) {
      // Background refresh xatolikni ignore qilish
    }
  }

  /// Cache'dan yuklash
  Future<List<ServicePlace>?> _loadFromCache(String? type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cache timestamp'ni tekshirish
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheDate) > _cacheExpiry) {
          // Cache eskirgan
          return null;
        }
      }

      final cacheKey = type != null ? '${_cacheKey}_$type' : _cacheKey;
      final cachedJson = prefs.getString(cacheKey);
      
      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        return decoded.map((json) => ServicePlace.fromJson(json)).toList();
      }
    } catch (e) {
      print('Cache load error: $e');
    }
    return null;
  }

  /// Cache'ga saqlash
  Future<void> _saveToCache(List<ServicePlace> places, String? type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cacheKey = type != null ? '${_cacheKey}_$type' : _cacheKey;
      final jsonData = jsonEncode(places.map((p) => p.toJson()).toList());
      
      await prefs.setString(cacheKey, jsonData);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  /// Masofaga ko'ra filter (offline)
  List<ServicePlace> _filterByDistance(
    List<ServicePlace> places,
    double latitude,
    double longitude,
    double radius,
  ) {
    // Simple distance calculation (Haversine formula)
    return places.where((place) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        place.location.latitude,
        place.location.longitude,
      );
      return distance <= radius;
    }).toList()
      ..sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.location.latitude,
          a.location.longitude,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.location.latitude,
          b.location.longitude,
        );
        return distA.compareTo(distB);
      });
  }

  /// Masofa hisoblash (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metrda

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Cache'ni tozalash
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }
}
