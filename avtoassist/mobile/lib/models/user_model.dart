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
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'client',
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      providerId: (json['provider_id'] as num?)?.toInt(),
      serviceType: json['service_type'] as String?,
      businessName: json['business_name'] as String?,
      isAvailable: json['is_available'] as bool?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalOrders: (json['total_orders'] as num?)?.toInt(),
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
