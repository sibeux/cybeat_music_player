import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:cybeat_music_player/core/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;

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
          // ambil token dari secure storage / singleton authservice
          final token = await getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // misal handle 401
          if (error.response?.statusCode == 401) {
            try {
              final newToken = await Get.find<AuthService>().refreshJwtToken();

              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              final response = await dio.fetch(error.requestOptions);

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

  Future<String?> getToken() async {
    final storage = Get.find<SecureStorageService>();
    final token = await storage.getAccessToken();
    return token;
  }
}
