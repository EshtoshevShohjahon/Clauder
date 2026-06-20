import 'package:flutter/material.dart';

class AppIcons {
  // Service Icons
  static const IconData mechanic = Icons.build;
  static const IconData fuelDelivery = Icons.local_gas_station;
  static const IconData carWash = Icons.local_car_wash;
  static const IconData partsSeller = Icons.settings;
  static const IconData workshop = Icons.home_repair_service;
  static const IconData towTruck = Icons.local_shipping;
  
  // Navigation Icons
  static const IconData home = Icons.home_outlined;
  static const IconData orders = Icons.list_alt_outlined;
  static const IconData profile = Icons.person_outline;
  
  // Action Icons
  static const IconData search = Icons.search;
  static const IconData filter = Icons.tune;
  static const IconData location = Icons.location_on;
  static const IconData phone = Icons.phone;
  static const IconData message = Icons.message;
  static const IconData star = Icons.star;
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData close = Icons.close;
  static const IconData check = Icons.check;
  
  // Map service type to icon
  static IconData getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'mechanic':
        return mechanic;
      case 'fuel_delivery':
        return fuelDelivery;
      case 'car_wash':
        return carWash;
      case 'parts_seller':
        return partsSeller;
      case 'workshop':
        return workshop;
      case 'tow_truck':
        return towTruck;
      default:
        return Icons.help_outline;
    }
  }
  
  // Get service name
  static String getServiceName(String serviceType) {
    switch (serviceType) {
      case 'mechanic':
        return 'Texnik yordam';
      case 'fuel_delivery':
        return 'Yoqilg\'i quyish';
      case 'car_wash':
        return 'Avtomobil yuvish';
      case 'parts_seller':
        return 'Ehtiyot qismlar';
      case 'workshop':
        return 'Ustaxonalar';
      case 'tow_truck':
        return 'Evakuator';
      default:
        return serviceType;
    }
  }
}
