import 'package:avtoassist/models/location_model.dart';

class Order {
  final int id;
  final int clientId;
  final int? providerId;
  final String serviceType;
  final String? description;
  final LocationCoordinates pickupLocation;
  final LocationCoordinates? destinationLocation;
  final String status;
  final double? price;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  
  // Additional info
  final String? clientName;
  final String? clientPhone;
  final String? providerName;
  final String? providerPhone;
  final double? providerRating;

  Order({
    required this.id,
    required this.clientId,
    this.providerId,
    required this.serviceType,
    this.description,
    required this.pickupLocation,
    this.destinationLocation,
    required this.status,
    this.price,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.clientName,
    this.clientPhone,
    this.providerName,
    this.providerPhone,
    this.providerRating,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      providerId: json['provider_id'] as int?,
      serviceType: json['service_type'] as String,
      description: json['description'] as String?,
      pickupLocation: LocationCoordinates.fromString(json['pickup_coords'] as String? ?? 'POINT(0 0)'),
      destinationLocation: json['destination_coords'] != null 
          ? LocationCoordinates.fromString(json['destination_coords'] as String)
          : null,
      status: json['status'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at'] as String) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      clientName: json['client_name'] as String?,
      clientPhone: json['client_phone'] as String?,
      providerName: json['provider_name'] as String?,
      providerPhone: json['provider_phone'] as String?,
      providerRating: json['provider_rating'] != null 
          ? (json['provider_rating'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'provider_id': providerId,
      'service_type': serviceType,
      'description': description,
      'pickup_location': pickupLocation.toPointString(),
      'destination_location': destinationLocation?.toPointString(),
      'status': status,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => isPending || isAccepted || isInProgress;

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'accepted':
        return 'Qabul qilindi';
      case 'in_progress':
        return 'Bajarilmoqda';
      case 'completed':
        return 'Yakunlandi';
      case 'cancelled':
        return 'Bekor qilindi';
      default:
        return status;
    }
  }

  Order copyWith({
    int? id,
    int? clientId,
    int? providerId,
    String? serviceType,
    String? description,
    LocationCoordinates? pickupLocation,
    LocationCoordinates? destinationLocation,
    String? status,
    double? price,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? clientName,
    String? clientPhone,
    String? providerName,
    String? providerPhone,
    double? providerRating,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      status: status ?? this.status,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerRating: providerRating ?? this.providerRating,
    );
  }
}
