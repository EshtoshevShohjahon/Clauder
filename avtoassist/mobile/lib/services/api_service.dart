import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:avtoassist/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyToken, token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.keyToken);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
  }

  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(needsAuth: needsAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Vaqt tugadi. Internetni tekshiring.');
        },
      );

      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Internet aloqasi yo\'q');
    } catch (e) {
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Tarmoq xatosi: Iltimos qaytadan urinib ko\'ring');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool needsAuth = false,
  }) async {
    try {
      var url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        url,
        headers: _getHeaders(needsAuth: needsAuth),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Vaqt tugadi. Internetni tekshiring.');
        },
      );

      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Internet aloqasi yo\'q');
    } catch (e) {
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Tarmoq xatosi: Iltimos qaytadan urinib ko\'ring');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(needsAuth: needsAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Tarmoq xatosi: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Server xatosi');
    }
  }
}
