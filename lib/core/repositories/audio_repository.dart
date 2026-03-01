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
        options: Options(
          validateStatus: (status) {
            return status == 200 || status == 401 || status == 403;
          },
        ),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        logWarning("You have no authority to access this $albumType");
        return {};
      } else {
        throw Exception('Failed to get songs. Error: ${response.statusCode}');
      }
    } on TimeoutException {
      logError('getSongs timed out for albumId=$albumId, type=$albumType');
      return {};
    } catch (e) {
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
      final response = await dio.post(
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
        options: Options(
          validateStatus: (status) {
            return status == 200 ||
                status == 400 ||
                status == 401 ||
                status == 403 ||
                status == 500;
          },
        ),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 400) {
        logError(
            'setRecentCodecDominantColor: 400 Bad Request. Check POST fields. Response: ${response.data}');
        return {};
      } else if (response.statusCode == 500) {
        throw Exception(
            'Failed to setRecentCodecDominantColor. Error: ${response.data}. Status code: ${response.statusCode}');
      } else {
        throw Exception(
            'Failed to setRecentCodecDominantColor. Error: ${response.data}. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
          'Failed to setRecentCodecDominantColor. Error: TimeoutException');
    } on DioException catch (e) {
      throw Exception(
          'Failed to setRecentCodecDominantColor. Error: DioException ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
