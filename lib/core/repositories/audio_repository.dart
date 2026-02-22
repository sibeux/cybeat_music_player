import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/networks/dio_client.dart';
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
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get songs. Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
