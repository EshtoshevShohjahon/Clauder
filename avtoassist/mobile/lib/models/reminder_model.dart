class MaintenanceReminder {
  final int id;
  final int userId;
  final int vehicleId;
  final String reminderType;
  final String title;
  final String? description;
  final int? dueMileage;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  
  // Extra fields from join
  final String? vehicleBrand;
  final String? vehicleModel;
  final int? currentMileage;

  MaintenanceReminder({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.reminderType,
    required this.title,
    this.description,
    this.dueMileage,
    this.dueDate,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    this.vehicleBrand,
    this.vehicleModel,
    this.currentMileage,
  });

  factory MaintenanceReminder.fromJson(Map<String, dynamic> json) {
    return MaintenanceReminder(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      reminderType: json['reminder_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueMileage: json['due_mileage'] as int?,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      vehicleBrand: json['brand'] as String?,
      vehicleModel: json['model'] as String?,
      currentMileage: json['current_mileage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminder_type': reminderType,
      'title': title,
      'description': description,
      'due_mileage': dueMileage,
      'due_date': dueDate?.toIso8601String().split('T')[0],
    };
  }

  String get reminderTypeText {
    switch (reminderType) {
      case 'oil_change':
        return '🛢️ Moy almashtirish';
      case 'tire_rotation':
        return '🔄 Shinalar almashtirish';
      case 'brake_check':
        return '🛑 Tormoz tekshiruvi';
      case 'filter_change':
        return '🔧 Filtr almashtirish';
      case 'battery_check':
        return '🔋 Akkumulyator tekshiruvi';
      case 'general_service':
        return '⚙️ Umumiy texnik xizmat';
      default:
        return reminderType;
    }
  }

  int? get remainingKm {
    if (dueMileage == null || currentMileage == null) return null;
    return dueMileage! - currentMileage!;
  }

  bool get isOverdue {
    if (dueDate != null) {
      return dueDate!.isBefore(DateTime.now());
    }
    if (remainingKm != null) {
      return remainingKm! <= 0;
    }
    return false;
  }

  bool get isUrgent {
    if (dueDate != null) {
      final daysLeft = dueDate!.difference(DateTime.now()).inDays;
      return daysLeft <= 7 && daysLeft >= 0;
    }
    if (remainingKm != null) {
      return remainingKm! <= 500 && remainingKm! > 0;
    }
    return false;
  }
}
