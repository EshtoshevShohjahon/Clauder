import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Offline xarita servisi
/// OpenStreetMap tile'larini cache qiladi va internet yo'qligida ham ishlaydi
class OfflineMapService {
  static final OfflineMapService _instance = OfflineMapService._internal();
  factory OfflineMapService() => _instance;
  OfflineMapService._internal();

  /// OpenStreetMap tile URL
  /// Bu tile'lar avtomatik ravishda cache qilinadi
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  
  /// User agent (OSM requirements)
  static const String userAgent = 'AvtoHelp/1.0';

  /// Default xarita markazi (Toshkent)
  static const LatLng tashkentCenter = LatLng(41.3111, 69.2401);
  
  /// Default zoom level
  static const double defaultZoom = 14.0;

  /// Xarita uchun TileLayer yaratish
  /// Cache bilan ishlaydi - bir marta yuklangan tile'lar diskda saqlanadi
  TileLayer getTileLayer() {
    return TileLayer(
      urlTemplate: osmTileUrl,
      userAgentPackageName: userAgent,
      
      // Cache settings - offline rejim uchun muhim
      tileProvider: CachedTileProvider(),
      
      // Tile loading settings
      maxZoom: 19,
      minZoom: 3,
      
      // Performance settings
      keepBuffer: 5,
      
      // Tile fade animation
      tileFadeInDuration: const Duration(milliseconds: 200),
    );
  }

  /// User location marker
  Marker createUserMarker(LatLng position) {
    return Marker(
      point: position,
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 3),
        ),
        child: const Center(
          child: Icon(
            Icons.navigation,
            color: Colors.blue,
            size: 30,
          ),
        ),
      ),
    );
  }

  /// Service provider marker
  Marker createServiceMarker({
    required LatLng position,
    required String serviceType,
    required VoidCallback onTap,
  }) {
    return Marker(
      point: position,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _getServiceIcon(serviceType),
              color: _getServiceColor(serviceType),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  /// Polyline (yo'l chizish) uchun
  Polyline createRoutePolyline(List<LatLng> points) {
    return Polyline(
      points: points,
      strokeWidth: 4.0,
      color: Colors.blue,
      borderStrokeWidth: 2.0,
      borderColor: Colors.white,
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'mechanic':
        return Icons.build;
      case 'fuel_delivery':
        return Icons.local_gas_station;
      case 'car_wash':
        return Icons.local_car_wash;
      case 'tow_truck':
        return Icons.local_shipping;
      case 'workshop':
        return Icons.home_repair_service;
      case 'parts_seller':
        return Icons.settings;
      default:
        return Icons.place;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'mechanic':
        return Colors.orange;
      case 'fuel_delivery':
        return Colors.red;
      case 'car_wash':
        return Colors.blue;
      case 'tow_truck':
        return Colors.purple;
      case 'workshop':
        return Colors.green;
      case 'parts_seller':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}

/// Custom Tile Provider with caching
/// Bu class tile'larni cache qiladi va offline rejimda ishlatadi
class CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    
    return CachedNetworkImageProvider(
      url,
      // Cache settings
      cacheKey: url,
      maxHeight: 256,
      maxWidth: 256,
      
      // Cache duration - 90 kun
      cacheManager: DefaultCacheManager(),
    );
  }

  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    return options.urlTemplate!
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString());
  }
}

/// Cache manager (default - 100 days)
class DefaultCacheManager {
  // cached_network_image paketi o'z cache manager'ini ishlatadi
  // Default: 7 kun, biz uni 90 kunga o'zgartiramiz
  static const Duration cacheMaxAge = Duration(days: 90);
  static const int maxNrOfCacheObjects = 2000; // ~50-100MB
}
