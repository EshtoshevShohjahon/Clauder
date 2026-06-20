class User {
  final int id;
  final String phone;
  final String? fullName;
  final String role; // 'client' or 'provider'
  final bool phoneVerified;
  final DateTime createdAt;
  
  // Provider-specific fields
  final int? providerId;
  final String? serviceType;
  final String? businessName;
  final bool? isAvailable;
  final double? rating;
  final int? totalOrders;

  User({
    required this.id,
    required this.phone,
    this.fullName,
    required this.role,
    required this.phoneVerified,
    required this.createdAt,
    this.providerId,
    this.serviceType,
    this.businessName,
    this.isAvailable,
    this.rating,
    this.totalOrders,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      providerId: json['provider_id'] as int?,
      serviceType: json['service_type'] as String?,
      businessName: json['business_name'] as String?,
      isAvailable: json['is_available'] as bool?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalOrders: json['total_orders'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'phone_verified': phoneVerified,
      'created_at': createdAt.toIso8601String(),
      'provider_id': providerId,
      'service_type': serviceType,
      'business_name': businessName,
      'is_available': isAvailable,
      'rating': rating,
      'total_orders': totalOrders,
    };
  }

  bool get isClient => role == 'client';
  bool get isProvider => role == 'provider';

  User copyWith({
    int? id,
    String? phone,
    String? fullName,
    String? role,
    bool? phoneVerified,
    DateTime? createdAt,
    int? providerId,
    String? serviceType,
    String? businessName,
    bool? isAvailable,
    double? rating,
    int? totalOrders,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      businessName: businessName ?? this.businessName,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}
