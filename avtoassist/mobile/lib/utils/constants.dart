class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const String wsUrl = 'ws://localhost:3000';
  
  // Production URLs (o'zgartiring)
  // static const String baseUrl = 'https://api.avtoassist.uz/api';
  // static const String wsUrl = 'wss://api.avtoassist.uz';
  
  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authVerifyPhone = '/auth/verify-phone';
  static const String authSelectRole = '/auth/select-role';
  
  static const String ordersCreate = '/orders';
  static const String ordersGet = '/orders';
  static const String ordersAccept = '/orders/{id}/accept';
  static const String ordersStatus = '/orders/{id}/status';
  static const String ordersComplete = '/orders/{id}/complete';
  static const String ordersCancel = '/orders/{id}/cancel';
  static const String ordersRate = '/orders/{id}/rate';
  
  static const String providersNearby = '/providers/nearby';
  static const String providersWorkshops = '/providers/workshops';
  static const String providersParts = '/providers/parts';
  
  static const String userProfile = '/users/me';
  static const String userLocation = '/users/me/location';
  
  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserPhone = 'user_phone';
  
  // Service Types
  static const String serviceMechanic = 'mechanic';
  static const String serviceFuelDelivery = 'fuel_delivery';
  static const String serviceCarWash = 'car_wash';
  static const String servicePartsSeller = 'parts_seller';
  static const String serviceWorkshop = 'workshop';
  static const String serviceTowTruck = 'tow_truck';
  
  // Order Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // Map Configuration
  static const double defaultLatitude = 41.3111;
  static const double defaultLongitude = 69.2401;
  static const double defaultZoom = 14.0;
  static const double nearbyRadius = 10000; // 10km
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
