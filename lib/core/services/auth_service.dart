import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/repositories/auth_repository.dart';
import 'package:cybeat_music_player/core/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService extends GetxService {
  final _storage = Get.find<SecureStorageService>();
  final AuthRepository _authRepo = AuthRepository();

  RxInt userId = 0.obs;
  RxString fullName = "".obs;

  var accessToken = "".obs;
  DateTime? expiry;
  var isTokenValid = false.obs;

  // Derived getter - KISS principle
  // KISS: Keep It Simple, Stupid
  bool get isAuthenticated => isTokenValid.value;
  RxString get getAccessToken => accessToken;

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

  void updateCredentials({
    required String newAccessToken,
    required String newRefreshToken,
  }) {
    isTokenValid.value = true;
    accessToken.value = newAccessToken;
    expiry = _decodeExpiry(newAccessToken);
    // Simpan token baru ke secure storage
    _storage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(newAccessToken);
    userId.value = decodedToken['sub']; // 'sub' biasanya digunakan untuk menyimpan user ID dalam JWT
    fullName.value = decodedToken['data']['name'];
  }

  Future<void> checkJwtToken() async {
    try {
      final isValid = await _authRepo.checkJwtToken(accessToken.value);
      if (isValid) {
        logSuccess('JWT token is valid. User authenticated.');
        updateCredentials(
          newAccessToken: accessToken.value,
          // Sengaja dikosongkan agar refresh token tidak ter-overwrite saat validasi token,
          // karena biasanya refresh token tidak berubah kecuali saat refresh token itu sendiri digunakan.
          newRefreshToken: "",
        );
      } else {
        logInfo('JWT token is invalid or expired. Logging out.');
        logout();
      }
    } catch (e) {
      logError('Error checking JWT token: $e');
    }
  }

  Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final result = await _authRepo.createUser(
        name: name,
        email: email,
        password: password,
      );

      // Logika bisnis: Cek status dari response API
      if (result['status'] == 'success') {
        final newAccess = result['access_token'].toString();
        final newRefresh = result['refresh_token'] != null ? result['refresh_token'].toString() : "";
        updateCredentials(
          newAccessToken: newAccess,
          newRefreshToken: newRefresh,
        );
        return true;
      } else {
        // Lempar pesan error spesifik dari API
        throw result['message'] ?? 'Registration failed';
      }
    } catch (e) {
      // Lempar kembali error agar ditangkap Controller
      rethrow;
    }
  }
}
