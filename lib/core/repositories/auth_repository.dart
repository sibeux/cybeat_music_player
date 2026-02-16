import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthRepository {
  Future<bool> checkJwtToken(String token) async {
    final url = Uri.parse('https://api.example.com/auth/refresh');

    try {
      final response = await http.post(
        url,
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
}
