import 'package:avtoassist/models/location_model.dart';

class Provider {
  final int id;
  final int userId;
  final String serviceType;
  final String? businessName;
  final double rating;
  final int totalOrders;
  final bool isAvailable;
  final LocationCoordinates? currentLocation;
  final DateTime? lastLocationUpdate;
  
  // User info
  final String? fullName;
  final String? phone;
  
  // Distance (calculated when fetching nearby)
  final double? distance;

  Provider({
    required this.id,
    required this.userId,
    required this.serviceType,
    this.businessName,
    required this.rating,
    required this.totalOrders,
    required this.isAvailable,
    this.currentLocation,
    this.lastLocationUpdate,
    this.fullName,
    this.phone,
    this.distance,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    LocationCoordinates? location;
    if (json['current_coords'] != null) {
      location = LocationCoordinates.fromString(json['current_coords'] as String);
    }

    return Provider(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      serviceType: json['service_type'] as String,
      businessName: json['business_name'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      currentLocation: location,
      lastLocationUpdate: json['last_location_update'] != null
          ? DateTime.parse(json['last_location_update'] as String)
          : null,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_type': serviceType,
      'business_name': businessName,
      'rating': rating,
      'total_orders': totalOrders,
      'is_available': isAvailable,
      'current_location': currentLocation?.toPointString(),
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'full_name': fullName,
      'phone': phone,
      'distance': distance,
    };
  }

  String get displayName => businessName ?? fullName ?? 'Provider';
  
  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  Provider copyWith({
    int? id,
    int? userId,
    String? serviceType,
    String? businessName,
    double? rating,
    int? totalOrders,
    bool? isAvailable,
    LocationCoordinates? currentLocation,
    DateTime? lastLocationUpdate,
    String? fullName,
    String? phone,
    double? distance,
  }) {
    return Provider(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      businessName: businessName ?? this.businessName,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLocation: currentLocation ?? this.currentLocation,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      distance: distance ?? this.distance,
    );
  }
}
