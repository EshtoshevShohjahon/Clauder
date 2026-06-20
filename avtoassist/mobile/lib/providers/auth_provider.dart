import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avtoassist/models/user_model.dart';
import 'package:avtoassist/services/api_service.dart';
import 'package:avtoassist/utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> loadUser() async {
    try {
      await _api.loadToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(AppConstants.keyUserId);
      
      if (userId != null) {
        final response = await _api.get(
          AppConstants.userProfile,
          needsAuth: true,
        );
        
        if (response['success'] == true) {
          _user = User.fromJson(response['data']['user']);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> register({
    required String phone,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        AppConstants.authRegister,
        body: {
          'phone': phone,
          'password': password,
          'full_name': fullName,
        },
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);
        
        await _api.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(AppConstants.keyUserId, _user!.id);
        
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

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        AppConstants.authLogin,
        body: {
          'phone': phone,
          'password': password,
        },
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);
        
        await _api.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(AppConstants.keyUserId, _user!.id);
        
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

  Future<void> logout() async {
    _user = null;
    await _api.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  Future<bool> selectRole(String role, {String? serviceType}) async {
    try {
      final response = await _api.post(
        AppConstants.authSelectRole,
        body: {
          'phone': _user?.phone,
          'role': role,
          if (serviceType != null) 'service_type': serviceType,
        },
      );

      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
