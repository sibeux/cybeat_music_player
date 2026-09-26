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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString().isNotEmpty ? options.uri.toString() : options.path;
    logInfo('$method $url');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final url = response.requestOptions.uri.toString().isNotEmpty
        ? response.requestOptions.uri.toString()
        : response.requestOptions.path;
    logSuccess('$url\nSUCCESS');
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final url = requestOptions.uri.toString().isNotEmpty
        ? requestOptions.uri.toString()
        : requestOptions.path;

    // Format error message (menangkap 'Failed host lookup' / DNS error)
    final errorMsg = _extractErrorMessage(err);
    final isRetry = (requestOptions.extra['retry_count'] ?? 0) > 0;

    if (isRetry) {
      logWarning('retry ($url)\n$errorMsg');
    } else {
      logError('$url\n$errorMsg', error: err.error ?? err);
    }

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

        await Future.delayed(delay);

        // Jika request dibatalkan saat sedang jeda retry
        if (requestOptions.cancelToken?.isCancelled ?? false) {
          return handler.next(err);
        }

        try {
          // Jika request menggunakan FormData, clone FormData agar tidak terjadi
          // 'Bad state: The FormData has already been finalized' saat retry
          dynamic requestData = requestOptions.data;
          if (requestData is FormData) {
            requestData = requestData.clone();
          }

          final response = await dio.fetch(requestOptions.copyWith(data: requestData));
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

  String _extractErrorMessage(DioException err) {
    final rawError = err.error?.toString() ?? '';
    final message = err.message ?? '';

    if (rawError.contains('Failed host lookup') || message.contains('Failed host lookup')) {
      return 'Failed host lookup';
    }
    if (rawError.contains('Connection refused') || message.contains('Connection refused')) {
      return 'Connection refused';
    }
    if (err.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    }
    if (err.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    }
    if (err.type == DioExceptionType.sendTimeout) {
      return 'Send timeout';
    }
    if (err.error is SocketException) {
      final sockErr = err.error as SocketException;
      return sockErr.message.isNotEmpty ? sockErr.message : 'Network error';
    }
    return message.isNotEmpty ? message : (rawError.isNotEmpty ? rawError : 'Network error');
  }
}
