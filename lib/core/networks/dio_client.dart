import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  
  // Flag & Queue untuk menangani request yang datang berbarengan
  bool _isRefreshing = false;
  final List<void Function(String)> _requestQueue = [];

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // Lapis Pertahanan 1: Proaktif (Cek sebelum kirim)
        onRequest: (options, handler) async {
          final authService = Get.find<AuthService>();

          // Jika user sudah login dan token terdeteksi expired di sisi client
          if (authService.isAuthenticated && authService.isExpired()) {
            
            // Gunakan lock agar tidak terjadi multiple refresh call
            if (!_isRefreshing) {
              _isRefreshing = true;
              try {
                logInfo("Trying to refresh token");
                final String newToken = await authService.refreshJwtToken();
                _isRefreshing = false;
                
                // Jalankan antrean jika ada yang menunggu
                for (var callback in _requestQueue) {
                  callback(newToken);
                }
                _requestQueue.clear();

                options.headers['Authorization'] = 'Bearer $newToken';
              } catch (e) {
                _isRefreshing = false;
                _requestQueue.clear();
                // Jika refresh gagal, biarkan lanjut (nanti backend handle sebagai guest)
              }
            } else {
              // Jika sedang ada refresh berjalan, masukkan request ini ke antrean
              _requestQueue.add((String newToken) {
                options.headers['Authorization'] = 'Bearer $newToken';
                handler.next(options);
              });
              return; // Tahan request ini sampai callback dipanggil
            }
          } else {
            // Jika token masih valid, langsung pasang
            final token = authService.accessToken.value;
            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          
          return handler.next(options);
        },

        // Lapis Pertahanan 2: Defensif (Jaring pengaman jika server tiba-tiba kirim 401)
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && 
              !error.requestOptions.path.contains('auth')) {
            
            try {
              final authService = Get.find<AuthService>();
              final String newToken = await authService.refreshJwtToken();

              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // Retry request secara transparan
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
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}