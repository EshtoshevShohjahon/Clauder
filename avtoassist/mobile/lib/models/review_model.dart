class Review {
  final int id;
  final int orderId;
  final int providerId;
  final int clientId;
  final int rating;
  final String? comment;
  final String? clientName;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.orderId,
    required this.providerId,
    required this.clientId,
    required this.rating,
    this.comment,
    this.clientName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      providerId: json['provider_id'] as int,
      clientId: json['client_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      clientName: json['client_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'provider_id': providerId,
      'client_id': clientId,
      'rating': rating,
      'comment': comment,
      'client_name': clientName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
