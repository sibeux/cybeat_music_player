import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RegisterRepository {
  Future<bool> checkEmail({required String email}) async {
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
          'method': 'email_check',
          'email': email,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Mengembalikan nilai boolean hasil pengecekan
        return jsonResponse['email_exists'].toString() == 'true';
      } else {
        // Melempar error agar ditangkap Controller
        throw Exception('Failed checking. Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Meneruskan error (Timeout/Network) ke Controller
    }
  }
}
