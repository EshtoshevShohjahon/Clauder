import 'package:avtoassist/models/location_model.dart';

class Part {
  final int id;
  final String name;
  final String? category;
  final String? description;
  final double? price;
  final String? shopName;
  final LocationCoordinates? shopLocation;
  final bool inStock;
  final String? imageUrl;
  final DateTime createdAt;

  Part({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.price,
    this.shopName,
    this.shopLocation,
    required this.inStock,
    this.imageUrl,
    required this.createdAt,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    LocationCoordinates? location;
    if (json['shop_location'] != null) {
      location = LocationCoordinates.fromString(json['shop_location'] as String);
    }

    return Part(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      shopName: json['shop_name'] as String?,
      shopLocation: location,
      inStock: json['in_stock'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'shop_name': shopName,
      'shop_location': shopLocation?.toPointString(),
      'in_stock': inStock,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get priceText {
    if (price == null) return 'Narx so\'ralsin';
    return '${price!.toStringAsFixed(0)} so\'m';
  }

  String get stockText => inStock ? 'Mavjud' : 'Mavjud emas';
}
