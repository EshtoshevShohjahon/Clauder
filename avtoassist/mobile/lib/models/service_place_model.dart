import 'package:latlong2/latlong.dart';

/// Xizmat ko'rsatuvchi model (offline cache uchun)
class ServicePlace {
  final int id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final String? phone2;
  final LatLng location;
  final String? workingHours;
  final double rating;
  final String? description;
  final double? distance; // Foydalanuvchidan masofa (metrda)

  ServicePlace({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    this.phone2,
    required this.location,
    this.workingHours,
    required this.rating,
    this.description,
    this.distance,
  });

  factory ServicePlace.fromJson(Map<String, dynamic> json) {
    return ServicePlace(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      phone: json['phone'],
      phone2: json['phone_2'],
      location: LatLng(
        json['latitude'].toDouble(),
        json['longitude'].toDouble(),
      ),
      workingHours: json['working_hours'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      description: json['description'],
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'phone': phone,
      'phone_2': phone2,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'working_hours': workingHours,
      'rating': rating,
      'description': description,
      'distance': distance,
    };
  }

  /// Type'ning o'zbek nomi
  String get typeName {
    switch (type) {
      case 'gas_station':
        return 'Yoqilg\'i quyish';
      case 'auto_parts':
        return 'Ehtiyot qismlar';
      case 'workshop':
        return 'Avto ustaxona';
      case 'evacuator':
        return 'Evakuator';
      case 'car_wash':
        return 'Avto yuvish';
      case 'tire_service':
        return 'Shinomontaj';
      default:
        return type;
    }
  }

  /// Masofani formatlash
  String get formattedDistance {
    if (distance == null) return '';
    
    if (distance! < 1000) {
      return '${distance!.toStringAsFixed(0)} m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)} km';
    }
  }
}
