class OilChange {
  final int id;
  final int userId;
  final int vehicleId;
  final String oilType;
  final String? oilBrand;
  final int mileage;
  final int? nextChangeMileage;
  final String? location;
  final String? workshopName;
  final double? price;
  final String? notes;
  final DateTime changedAt;
  final DateTime createdAt;

  OilChange({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.oilType,
    this.oilBrand,
    required this.mileage,
    this.nextChangeMileage,
    this.location,
    this.workshopName,
    this.price,
    this.notes,
    required this.changedAt,
    required this.createdAt,
  });

  factory OilChange.fromJson(Map<String, dynamic> json) {
    return OilChange(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      oilType: json['oil_type'] as String,
      oilBrand: json['oil_brand'] as String?,
      mileage: json['mileage'] as int,
      nextChangeMileage: json['next_change_mileage'] as int?,
      location: json['location'] as String?,
      workshopName: json['workshop_name'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oil_type': oilType,
      'oil_brand': oilBrand,
      'mileage': mileage,
      'next_change_mileage': nextChangeMileage,
      'location': location,
      'workshop_name': workshopName,
      'price': price,
      'notes': notes,
      'changed_at': changedAt.toIso8601String().split('T')[0],
    };
  }

  String get priceText {
    if (price == null) return 'Narx kiritilmagan';
    return '${price!.toStringAsFixed(0)} so\'m';
  }

  String get mileageText => '${mileage.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      )} km';

  String get nextChangeMileageText {
    if (nextChangeMileage == null) return '';
    return '${nextChangeMileage.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} km';
  }

  int? get remainingKm {
    if (nextChangeMileage == null) return null;
    return nextChangeMileage! - mileage;
  }

  bool get needsChange => remainingKm != null && remainingKm! <= 0;
}
