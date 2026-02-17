import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<bool> checkJwtToken(String token) async {
    final url = dotenv.env['VERIFY_JWT_API_URL'] ?? 'not_found';

    if (url == 'not_found') {
      logError('VERIFY_JWT_API_URL not found in environment variables');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return (jsonResponse['valid'] == 'true') &&
            (jsonResponse['exp'] == 'false');
      } else {
        // Melempar error agar ditangkap Controller
        throw Exception('Failed checking. Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Meneruskan error (Timeout/Network) ke Controller
    }
  }

  Future<Map<String, Object?>> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    String url = dotenv.env['REGISTER_AUTH_API_URL'] ?? 'not_found';

    if (url == 'not_found') {
      logError('API URL for registration not found in environment variables.');
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
        throw Exception('Failed checking. Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
