import 'dart:io';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Jangan retry jika request dibatalkan secara eksplisit oleh CancelToken
    if (err.type == DioExceptionType.cancel ||
        (requestOptions.cancelToken?.isCancelled ?? false)) {
      return handler.next(err);
    }

    // Cek apakah error merupakan transient network error atau server timeout/down
    final bool isConnectionError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.error is SocketException;

    final int? statusCode = err.response?.statusCode;
    final bool isServerError = statusCode != null &&
        (statusCode == 502 || statusCode == 503 || statusCode == 504);

    if (isConnectionError || isServerError) {
      int currentRetry = requestOptions.extra['retry_count'] ?? 0;

      if (currentRetry < maxRetries) {
        currentRetry++;
        requestOptions.extra['retry_count'] = currentRetry;

        // Exponential backoff: retry 1 -> 1s, retry 2 -> 2s, retry 3 -> 3s
        final delay = retryInterval * currentRetry;
        logWarning(
          'Network issue (${err.message ?? err.error}). Retrying ($currentRetry/$maxRetries) in ${delay.inSeconds}s -> ${requestOptions.uri}',
        );

        await Future.delayed(delay);

        // Jika request dibatalkan saat sedang jeda retry
        if (requestOptions.cancelToken?.isCancelled ?? false) {
          return handler.next(err);
        }

        try {
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          // onError akan terpanggil lagi untuk iterasi berikutnya (sampai maxRetries tercapai)
          return handler.next(retryErr);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }
}
