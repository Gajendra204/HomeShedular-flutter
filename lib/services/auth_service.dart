import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthService {
  // Get the appropriate base URL based on platform and environment
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/auth';
    } else if (Platform.isAndroid) {
      // For physical Android devices and emulators
      return 'http://192.168.1.13:3000/api/auth';
    } else if (Platform.isIOS) {
      // For physical iOS devices and simulators
      return 'http://192.168.1.13:3000/api/auth';
    }
    return 'http://192.168.1.13:3000/api/auth';
  }

  // Add debug method to test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      print('Connection test response: ${response.statusCode}');
      return response.statusCode != 404;
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['error']
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['error']
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }
}
