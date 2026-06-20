import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.101.130.41:3000/api'; // Kompyuter Wi-Fi IP (real qurilma uchun)
  static const String wsUrl = 'ws://10.101.130.41:3000';

  // Android emulator uchun:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String wsUrl = 'ws://10.0.2.2:3000';

  // Ilova versiyasi (in-app updater uchun)
  // Yangi APK chiqarganda bu raqamni oshiring (backend latest_build bilan solishtiriladi)
  static const int appVersionCode = 1;
  static const String appVersionName = '1.0.0';

  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authVerifyPhone = '/auth/verify-phone';
  static const String authSelectRole = '/auth/select-role';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  
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

  // Service Type IDs (string konstantalar)
  static const String serviceMechanic = 'mechanic';
  static const String serviceFuelDelivery = 'fuel_delivery';
  static const String serviceCarWash = 'car_wash';
  static const String servicePartsSeller = 'auto_parts';
  static const String serviceWorkshop = 'workshop';
  static const String serviceTowTruck = 'evacuator';
  
  // Service Types with map support
  static const List<Map<String, dynamic>> services = [
    {
      'id': 'mechanic',
      'name': 'Mexanik',
      'icon': Icons.build,
      'has_map': false,
    },
    {
      'id': 'fuel_delivery',
      'name': 'Yoqilg\'i yetkazish',
      'icon': Icons.local_gas_station,
      'has_map': false,
    },
    {
      'id': 'car_wash',
      'name': 'Avto yuvish',
      'icon': Icons.local_car_wash,
      'has_map': true,
      'place_type': 'car_wash',
    },
    {
      'id': 'auto_parts',
      'name': 'Ehtiyot qismlar',
      'icon': Icons.settings,
      'has_map': true,
      'place_type': 'auto_parts',
    },
    {
      'id': 'workshop',
      'name': 'Ustaxona',
      'icon': Icons.home_repair_service,
      'has_map': true,
      'place_type': 'workshop',
    },
    {
      'id': 'evacuator',
      'name': 'Evakuator',
      'icon': Icons.local_shipping,
      'has_map': true,
      'place_type': 'evacuator',
    },
    {
      'id': 'gas_stations',
      'name': 'Yoqilg\'i shoxoblari',
      'icon': Icons.local_gas_station,
      'has_map': true,
      'place_type': 'gas_station',
    },
  ];
  
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
