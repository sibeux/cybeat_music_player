import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;

  // Flag untuk menandai proses refresh sedang berjalan
  bool _isRefreshing = false;

  // Daftar antrean request yang gagal saat token sedang di-refresh
  final List<void Function(String)> _requestQueue = [];

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Pakai token dari AuthService yang reactive (.value)
          final authService = Get.find<AuthService>();
          final token = authService.accessToken.value;

          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized dan pastikan bukan request ke endpoint auth sendiri
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('auth')) {
            final requestOptions = error.requestOptions;

            // Jika sedang ada proses refresh, masukkan request ini ke antrean
            if (_isRefreshing) {
              _requestQueue.add((String newToken) async {
                requestOptions.headers['Authorization'] = 'Bearer $newToken';
                // Gunakan request() untuk mengulang dengan header terbaru
                handler.resolve(await dio.request(
                  requestOptions.path,
                  options: Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                  ),
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                ));
              });
              return;
            }

            // Kunci proses refresh
            _isRefreshing = true;

            try {
              final authService = Get.find<AuthService>();

              // Panggil refresh (AuthService otomatis simpan ke storage & update .value)
              final String newToken = await authService.refreshJwtToken();

              _isRefreshing = false; // Buka kunci

              // Update request yang gagal tadi
              requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // Jalankan SEMUA request yang ada di antrean
              for (var callback in _requestQueue) {
                callback(newToken);
              }
              _requestQueue.clear();

              // Retry request utama yang memicu refresh tadi
              final response = await dio.request(
                requestOptions.path,
                options: Options(
                  method: requestOptions.method,
                  headers: requestOptions.headers,
                ),
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
              );

              return handler.resolve(response);
            } catch (e) {
              _isRefreshing = false;
              _requestQueue.clear();
              // Jika refresh gagal (refresh token juga exp), AuthService sudah panggil logout()
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
