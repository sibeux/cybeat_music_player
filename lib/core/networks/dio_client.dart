import 'package:cybeat_music_player/core/networks/auth_interceptor.dart';
import 'package:dio/dio.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://api.example.com'),
    );
    dio.interceptors.add(AuthInterceptor(dio));
    return dio;
  }
}
