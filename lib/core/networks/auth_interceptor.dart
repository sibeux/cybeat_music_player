import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final auth = Get.find<AuthService>();

  bool isRefreshing = false;
  final queue = <RequestOptions>[];

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, handler) {
    final token = auth.accessToken.value;
    if (token.isEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, handler) async {
    if (err.response?.statusCode == 401) {
      queue.add(err.requestOptions);

      if (!isRefreshing) {
        isRefreshing = true;
        final ok = await auth.refreshToken();
        isRefreshing = false;

        if (!ok) {
          auth.logout();
          handler.reject(err);
          return;
        }

        for (final req in queue) {
          final res = await dio.fetch(req);
          handler.resolve(res);
        }
        queue.clear();
        return;
      }
    }
    handler.reject(err);
  }
}
