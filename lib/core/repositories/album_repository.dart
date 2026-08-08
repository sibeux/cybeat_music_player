import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/networks/dio_client.dart';
import 'package:dio/dio.dart';

class AlbumRepository {
  final dio = DioClient().dio;

  Future<Map<String, Object?>> fetchAlbums() async {
    String musicAlbumEndpoint = getEndpoint('MUSIC_ALBUM_API_URL');

    String sort = "";
    String filter = "";

    try {
      final response = await dio.get(
        musicAlbumEndpoint,
        queryParameters: {
          'sort': sort,
          'filter': filter,
        },
      ).timeout(const Duration(seconds: 60));
      // Dio otomatis mengonversi JSON menjadi Map, jadi tidak perlu jsonDecode manual
      return response.data;
    } on DioException catch (e) {
      // Jika Interceptor gagal refresh (misal refresh token habis),
      // dia akan melempar DioException 401 ke sini.
      if (e.response?.statusCode == 401) {
        logWarning(
            'Refresh gagal atau User memang Guest. Menampilkan data terbatas.');
        return e.response?.data; // Return data limited jika ada
      }
      logError('Critical error: ${e.toString()}');
      rethrow;
    }
  }

  Future<Map<String, Object?>> setPinData({
    required String action,
    required String albumId,
    required String albumType,
  }) async {
    String url = getEndpoint('PIN_ALBUM_API_URL');

    try {
      late Response<dynamic> response;
      if (action == "pin") {
        response = await dio.post(url, data: {
          'albumId': albumId,
          'albumType': albumType,
        }).timeout(const Duration(seconds: 10));
      } else if (action == "unpin") {
        response = await dio.delete(url, queryParameters: {
          'albumId': albumId,
          'albumType': albumType,
        }).timeout(const Duration(seconds: 10));
      } else {
        throw Exception('Invalid action: $action. Must be "pin" or "unpin".');
      }
      return response.data;
    } on DioException catch (e, st) {
      logError(
          'Critical error setPinData: ${e.toString()}, stackTrace: $st, ${e.response?.data}');
      rethrow;
    }
  }

  Future<Map<String, Object?>> getDominantColorAlbum({
    required String albumCover,
    required String albumId,
  }) async {
    final String url = getEndpoint('DOMINANT_COLOR_ALBUM_URL');
    try {
      final response = await dio.post(url, data: {
        'albumCover': albumCover,
        'albumId': albumId,
      }).timeout(const Duration(seconds: 10));
      return response.data;
    } on DioException catch (e, st) {
      logError(
          'Critical error getDominantColorAlbum: ${e.toString()}, stackTrace: $st, ${e.response?.data}');
      rethrow;
    }
  }
}
