import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/networks/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AlbumRepository {
  final dio = DioClient().dio;

  Future<Map<String, Object?>> fetchAlbums() async {
    String musicAlbumEndpoint =
        dotenv.env['MUSIC_ALBUM_API_URL'] ?? 'not_found';

    if (musicAlbumEndpoint == 'not_found') {
      throw Exception(
          'MUSIC_ALBUM_API_URL key-value pair not found in environment variables.');
    }

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
}
