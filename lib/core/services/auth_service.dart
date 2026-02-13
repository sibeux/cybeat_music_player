import 'dart:convert';

import 'package:cybeat_music_player/core/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final _storage = Get.find<SecureStorageService>();

  final accessToken = RxnString();
  DateTime? expiry;

  Future<AuthService> init() async {
    final token = await _storage.getAccessToken();
    final refresh = await _storage.getRefreshToken();

    if (token == null || refresh == null) return this;

    expiry = _decodeExpiry(token);
    accessToken.value = token;

    if (_isExpired()) {
      final success = await refreshToken();
      if (!success) logout();
    }

    return this;
  }

  bool _isExpired() => expiry == null || DateTime.now().isAfter(expiry!);

  DateTime _decodeExpiry(String jwt) {
    final payload = jsonDecode(
      utf8.decode(
        base64Url.decode(
          base64Url.normalize(jwt.split('.')[1]),
        ),
      ),
    );
    return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
  }

  Future<bool> refreshToken() async {
    try {
      final refresh = await _storage.getRefreshToken();
      if (refresh == null) return false;

      final dio = Dio();
      final res = await dio.post(
        'https://api.example.com/auth/refresh',
        data: {'refresh_token': refresh},
      );

      final newAccess = res.data['access_token'];
      final newRefresh = res.data['refresh_token'];

      expiry = _decodeExpiry(newAccess);
      accessToken.value = newAccess;

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    accessToken.value = null;
    expiry = null;
    _storage.clear();
    Get.offAllNamed('/login');
  }
}
