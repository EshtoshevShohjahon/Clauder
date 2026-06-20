import 'package:avtoassist/models/location_model.dart';

class Workshop {
  final int id;
  final String name;
  final String address;
  final LocationCoordinates location;
  final String? phone;
  final String? workingHours;
  final List<String> services;
  final double rating;
  final double? distance;

  Workshop({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.phone,
    this.workingHours,
    required this.services,
    required this.rating,
    this.distance,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      location: LocationCoordinates.fromString(json['location'] as String? ?? 'POINT(0 0)'),
      phone: json['phone'] as String?,
      workingHours: json['working_hours'] as String?,
      services: (json['services'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location.toPointString(),
      'phone': phone,
      'working_hours': workingHours,
      'services': services,
      'rating': rating,
      'distance': distance,
    };
  }

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }
}
