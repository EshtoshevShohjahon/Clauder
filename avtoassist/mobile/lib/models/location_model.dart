class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  // PostGIS POINT formatidan parse qilish: "POINT(69.2401 41.3111)"
  factory LocationCoordinates.fromString(String pointString) {
    final regex = RegExp(r'POINT\(([-\d.]+)\s+([-\d.]+)\)');
    final match = regex.firstMatch(pointString);
    
    if (match == null) {
      return LocationCoordinates(latitude: 0, longitude: 0);
    }
    
    final longitude = double.parse(match.group(1)!);
    final latitude = double.parse(match.group(2)!);
    
    return LocationCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // PostGIS POINT formatiga o'tkazish
  String toPointString() {
    return 'POINT($longitude $latitude)';
  }

  // Ikkita koordinata orasidagi masofa (km, Haversine formula)
  double distanceTo(LocationCoordinates other) {
    const earthRadius = 6371; // km
    
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);
    
    final a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(latitude).cos() * _toRadians(other.latitude).cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  @override
  String toString() {
    return 'LocationCoordinates(lat: $latitude, lon: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationCoordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
