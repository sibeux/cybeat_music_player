import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/repositories/auth_repository.dart';
import 'package:cybeat_music_player/core/services/secure_storage_service.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService extends GetxService {
  final _storage = Get.find<SecureStorageService>();
  final AuthRepository _authRepo = AuthRepository();

  RxInt userId = 0.obs;
  RxString fullName = "".obs;

  var accessToken = "".obs;
  DateTime? expiry;
  var isAccessTokenValid = false.obs;

  // Derived getter - KISS principle
  // KISS: Keep It Simple, Stupid
  bool get isAuthenticated => isAccessTokenValid.value;
  RxString get getAccessToken => accessToken;

  // * TICKET-20260216-01: Fix Null Check Operator Error
  // * Problem: `expiry!` was called even when `expiry` could be null, causing runtime crash.
  // * Solution: Use null-aware operator `?.` and specific boolean logic `?? true`.
  bool _isExpired() => expiry?.isBefore(DateTime.now()) ?? true;

  // Fungsinya saat app launch pertama kali, untuk cek apakah ada token di devic,
  // dan apakah token tersebut masih valid atau sudah expired.
  // kalau valid, maka user tetap login. Kalau expired, maka token dihapus dan user harus login ulang.
  // kalau token tidak ada, maka user harus login.
  Future<AuthService> init() async {
    try {
      final token = await _storage.getAccessToken();
      final refresh = await _storage.getRefreshToken();

      // Jika token atau refresh token tidak ditemukan, maka langsung return tanpa melakukan validasi,
      // karena tidak ada token yang bisa divalidasi. User harus login ulang.
      if (token == null || refresh == null) return this;

      accessToken.value = token;
      expiry = _decodeExpiry(token);

      // * TICKET-20260216-01: Added error handling to prevent silent initialization failures
      // * Problem: Previous implementation swallowed errors or threw unhandled exceptions
      // * Solution: Wrap initialization logic in try-catch and log errors
      // Jika token sudah expired, maka langsung refresh token.
      // Jika refresh token juga expired, maka user harus login ulang.
      if (_isExpired()) {
        isAccessTokenValid.value = false;
      } else {
        isAccessTokenValid.value = true;
        setCredentials(
          aksesToken: accessToken.value,
          // Tidak perlu update refresh token saat init, karena belum ada perubahan token.
          newRefreshToken: "", 
        );
      }
    } catch (e, stack) {
      logError('AuthService init error: $e\n$stack');
    }
    return this;
  }

  // Fungsinya untuk melakukan validasi token ke API, apakah refresh_token masih valid atau sudah expired.
  // Jika valid, maka generate access_token baru dan renew refresh_token.
  // Jika refresh_token expired, maka token dihapus dan user harus login ulang.
  Future<void> refreshJwtToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      final Map<String, Object?> data =
          await _authRepo.refreshJwtToken(refreshToken: refreshToken ?? '');
      if (data['status'] == 'success') {
        logSuccess(
            'Access token has been successfully Refreshed. Message: ${data['message']}');
        setCredentials(
          aksesToken: data['access_token'].toString(),
          newRefreshToken: data['refresh_token'] != null
              ? data['refresh_token'].toString()
              : "",
        );
      } else {
        logWarning(
            'JWT token is invalid or expired. Logging out. Message: ${data['message']}');
        logout();
      }
    } catch (e) {
      logError('Error checking JWT token: $e');
    }
  }

  // Fungsi untuk decode expiry dari JWT token, karena biasanya API tidak memberikan field expiry secara terpisah,
  // melainkan sudah termasuk dalam payload JWT token itu sendiri.
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

  void logout() {
    accessToken.value = "";
    expiry = null;
    _storage.clear();
  }

  void setCredentials({
    required String aksesToken,
    required String newRefreshToken,
  }) {
    isAccessTokenValid.value = true;
    accessToken.value = aksesToken;
    expiry = _decodeExpiry(aksesToken);
    // Simpan token baru ke secure storage
    _storage.saveTokens(
      accessToken: aksesToken,
      refreshToken: newRefreshToken,
    );
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(aksesToken);
    userId.value = decodedToken[
        'sub']; // 'sub' biasanya digunakan untuk menyimpan user ID dalam JWT
    fullName.value = decodedToken['data']['name'];
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
        final newRefresh = result['refresh_token'] != null
            ? result['refresh_token'].toString()
            : "";
        setCredentials(
          aksesToken: newAccess,
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
