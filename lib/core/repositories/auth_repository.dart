import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<Map<String, Object?>> refreshJwtToken(
      {required String refreshToken}) async {
    final url = dotenv.env['REFRESH_JWT_API_URL'] ?? 'not_found';

    if (url == 'not_found') {
      logError(
          'REFRESH_JWT_API_URL key-value pair not found in environment variables');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, Object?>> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    String url = dotenv.env['REGISTER_AUTH_API_URL'] ?? 'not_found';

    if (url == 'not_found') {
      logError(
          'REGISTER_AUTH_API_URL key-value pair not found in environment variables.');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'method': 'create_user',
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        // Melempar error ke service agar bisa ditangkap di Controller untuk ditampilkan ke user.
        throw Exception('Failed checking. Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Meneruskan error (Timeout/Network) ke service
    }
  }

  Future<Map<String, Object?>> loginUser({
    required String email,
    required String password,
  }) async {
    String url = dotenv.env['LOGIN_AUTH_API_URL'] ?? 'not_found';

    if (url == 'not_found') {
      logError(
          'LOGIN_AUTH_API_URL key-value pair not found in environment variables.');
    }

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 401) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        throw Exception(
            'Failed login. Error: ${response.statusCode}. Message: ${response.body}');
      }
    } catch (e) {
      rethrow; // Meneruskan error (Timeout/Network) ke service
    }
  }

  Future<Map<String, Object?>> logoutUser({required String refreshToken,}) async {
    String url = dotenv.env['LOGOUT_AUTH_API_URL'] ?? 'not_found';

    if (url == 'not_found') {
      logError(
          'LOGOUT_AUTH_API_URL key-value pair not found in environment variables.');
    }

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        throw Exception(
            'Failed logout. Error: ${response.statusCode}. Message: ${response.body}');
      }
    } catch (e) {
      rethrow; // Meneruskan error (Timeout/Network) ke service
    }
  }
}
