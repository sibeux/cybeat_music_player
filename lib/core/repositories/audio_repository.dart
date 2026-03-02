import 'dart:async';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/networks/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioRepository {
  final dio = DioClient().dio;

  Future<Map<String, Object?>> getSongs({
    required String albumType,
    required String albumId,
  }) async {
    String endpoint = dotenv.env['GET_SONG_API_URL'] ?? 'not_found';
    if (endpoint == 'not_found') {
      logError('GET_SONG_API_URL not found');
      return {};
    }
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: {
          'uid': albumId,
          'type': albumType,
        },
      ).timeout(const Duration(seconds: 30));
      return response.data;
    } on TimeoutException {
      logError('getSongs timed out for albumId=$albumId, type=$albumType');
      return {};
    } on DioException catch (e) {
      // Jika Interceptor gagal refresh (misal refresh token habis),
      // dia akan melempar DioException 401 ke sini.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        logWarning('User is not authorized. Showing limited data.');
        return e.response?.data; // Return data limited jika ada
      }

      logError('Critical error: ${e.toString()}');
      rethrow;
    }
  }

  // [CYBEAT-FLOW-001-E] Repository layer untuk set recent music, codec, dan dominant color.
  // Dipanggil dari AudioStateController.setRecentsCodecDominantColor secara fire & forget.
  // Lihat: docs/CYBEAT-FLOW-001_recent_codec_dominant_color.md
  Future<Map<String, Object?>> setRecentCodecDominantColor(
      {required int? musicId,
      required int albumId,
      required String albumType,
      required String musicUrl,
      required String imageUrl,
      required bool isCodecExist,
      required bool isDominantColorExist,
      required bool isFromGdrive}) async {
    String endpoint = dotenv.env['RECENT_MUSIC_API_URL'] ?? 'not_found';
    if (endpoint == 'not_found') {
      logError('RECENT_MUSIC_API_URL not found');
      return {};
    }
    try {
      final response = await dio
          .post(
            endpoint,
            // [CYBEAT-FLOW-001-E] WAJIB pakai FormData.fromMap(), BUKAN plain Map.
            // PHP $_POST hanya bisa baca multipart/form-data atau x-www-form-urlencoded.
            // Kalau dikirim sebagai JSON (Map biasa), $_POST di PHP akan kosong → 400 Bad Request.
            // Lihat BUG-002 di docs/CYBEAT-FLOW-001_recent_codec_dominant_color.md
            data: FormData.fromMap({
              'music_id': musicId,
              'album_id': albumId,
              'album_type': albumType,
              // Jika codec sudah ada ATAU berasal dari stream drive,
              // maka tidak perlu dicek lewat backend recent music.
              'codec_exist': (isCodecExist || isFromGdrive) ? "true" : "false",
              // Dominant color tidak perlu cek isFromGdrive karena hanya lewat recent.
              'dominant_color_exist': isDominantColorExist ? "true" : "false",
              'music_url': musicUrl,
              'image_url': imageUrl,
            }),
            // // Konfigurasi ini HANYA berlaku untuk request ini saja
            // options: Options(
            //   validateStatus: (status) {
            //     // Izinkan status 200 (Success) DAN 401 (Unauthorized) atau status lain
            //     // agar tidak langsung masuk ke catch block.
            //     return status == 200 ||
            //         status == 400 ||
            //         status == 401 ||
            //         status == 403 ||
            //         status == 500;
            //   },
            // ),
          )
          .timeout(const Duration(seconds: 30));

      return response.data;
    } on TimeoutException {
      throw Exception(
          'Failed to setRecentCodecDominantColor. Error: TimeoutException');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        logWarning('User is not authorized. Showing limited data.');
        return e.response?.data; // Return data limited jika ada
      } else if (e.response?.statusCode == 400) {
        logError(
            'setRecentCodecDominantColor: 400 Bad Request. Check POST fields. Response: ${e.response?.data}');
        return {};
      } else if (e.response?.statusCode == 500) {
        logError(
            'Failed to setRecentCodecDominantColor. Error: ${e.response?.data}. Status code: ${e.response?.statusCode}');
        return {};
      } else {
        logError(
            'Critical error in setRecentCodecDominantColor. Error: ${e.response?.data}. Status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
