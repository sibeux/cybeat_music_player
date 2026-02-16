import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final _storage = Get.find<SecureStorageService>();

  var accessToken = "".obs;
  DateTime? expiry;

  // Derived getter - KISS principle
  // KISS: Keep It Simple, Stupid
  bool get isAuthenticated => accessToken.value.isNotEmpty;

  Future<AuthService> init() async {
    try {
      final token = await _storage.getAccessToken();
      final refresh = await _storage.getRefreshToken();

      if (token == null || refresh == null) return this;

      expiry = _decodeExpiry(token);
      accessToken.value = token;

      // TICKET-20260216-01: Added error handling to prevent silent initialization failures
      // Problem: Previous implementation swallowed errors or threw unhandled exceptions
      // Solution: Wrap initialization logic in try-catch and log errors
      if (_isExpired()) {
        final success = await refreshToken();
        if (!success) logout();
      }
    } catch (e, stack) {
      logError('AuthService init error: $e\n$stack');
    }
    return this;
  }

  // TICKET-20260216-01: Fix Null Check Operator Error
  // Problem: `expiry!` was called even when `expiry` could be null, causing runtime crash.
  // Solution: Use null-aware operator `?.` and specific boolean logic `?? true`.
  bool _isExpired() => expiry?.isBefore(DateTime.now()) ?? true;

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
    accessToken.value = "";
    expiry = null;
    _storage.clear();
  }
}
