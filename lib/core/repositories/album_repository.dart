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
        // Konfigurasi ini HANYA berlaku untuk request ini saja
        options: Options(
          validateStatus: (status) {
            // Izinkan status 200 (Success) DAN 401 (Unauthorized)
            // agar tidak langsung masuk ke catch block
            return status == 200 || status == 401;
          },
        ),
      ).timeout(const Duration(seconds: 60));

      // Cek manual status code-nya
      if (response.statusCode == 401) {
        logWarning('User is guest/free, returning limited album data.');
        // Di sini kita bisa return data album "seadanya" dari response.data
        return response.data;
      }

      // Dio otomatis mengonversi JSON menjadi Map, jadi tidak perlu jsonDecode manual
      return response.data;
    } catch (e) {
      // Error selain 401 (seperti 500 atau No Internet) tetap masuk ke sini
      logError('Critical error fetching albums: ${e.toString()}');
      rethrow;
    }
  }
}
