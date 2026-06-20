import 'package:flutter/material.dart';
import 'package:avtoassist/models/order_model.dart';
import 'package:avtoassist/models/location_model.dart';
import 'package:avtoassist/services/api_service.dart';
import 'package:avtoassist/utils/constants.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Order> get activeOrders => 
      _orders.where((o) => o.isActive).toList();

  Future<bool> createOrder({
    required String serviceType,
    required LocationCoordinates pickupLocation,
    LocationCoordinates? destinationLocation,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        AppConstants.ordersCreate,
        body: {
          'service_type': serviceType,
          'pickup_location': pickupLocation.toPointString(),
          if (destinationLocation != null)
            'destination_location': destinationLocation.toPointString(),
          if (description != null) 'description': description,
        },
        needsAuth: true,
      );

      if (response['success'] == true) {
        final order = Order.fromJson(response['data']['order']);
        _orders.insert(0, order);
        _currentOrder = order;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOrders({String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(
        AppConstants.ordersGet,
        queryParams: status != null ? {'status': status} : null,
        needsAuth: true,
      );

      if (response['success'] == true) {
        final ordersData = response['data']['orders'] as List;
        _orders = ordersData.map((json) => Order.fromJson(json)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(int orderId) async {
    try {
      final endpoint = '/orders/$orderId/accept';
      final response = await _api.post(endpoint, needsAuth: true);

      if (response['success'] == true) {
        await fetchOrders();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final endpoint = '/orders/$orderId/status';
      final response = await _api.put(
        endpoint,
        body: {'status': status},
        needsAuth: true,
      );

      if (response['success'] == true) {
        await fetchOrders();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
