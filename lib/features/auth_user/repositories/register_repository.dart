import 'dart:convert';

import 'package:http/http.dart' as http;

class RegisterRepository {
  Future<bool> checkEmail({required String email}) async {
    const String url =
        'https://cybeat.sibeux.my.id/cloud-music-player/api/auth/register';

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
