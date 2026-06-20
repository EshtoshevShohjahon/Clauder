class Vehicle {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int? year;
  final String? plateNumber;
  final int currentMileage;
  final DateTime createdAt;
  final int? oilChangesCount;
  final DateTime? lastOilChange;

  Vehicle({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    this.year,
    this.plateNumber,
    required this.currentMileage,
    required this.createdAt,
    this.oilChangesCount,
    this.lastOilChange,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int?,
      plateNumber: json['plate_number'] as String?,
      currentMileage: json['current_mileage'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      oilChangesCount: json['oil_changes_count'] as int?,
      lastOilChange: json['last_oil_change'] != null
          ? DateTime.parse(json['last_oil_change'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'current_mileage': currentMileage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName => '$brand $model${year != null ? " ($year)" : ""}';

  String get mileageText => '${currentMileage.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      )} km';
}
