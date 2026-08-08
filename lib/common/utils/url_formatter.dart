import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String regexGdriveHostUrl({
  required String url,
  required bool isAudio,
  bool isAudioCached = false,
  bool isOffline = false,
  required String musicId,
}) {
  if (isOffline) {
    return url;
  }
  String musicStreamApi = dotenv.env['MUSIC_STREAM_API_URL'] ?? 'not_found';

  if (musicStreamApi.contains("not_found")) {
    logError("MUSIC_STREAM_API_URL is not exist in env variable");
    return "";
  }

  if (isAudio) {
    return "$musicStreamApi?music_id=$musicId&file_type=audio";
  } else {
    return "$musicStreamApi?file_type=image&cover_url=$url";
  }
}

String getEndpoint(String key) {
  final url = dotenv.env[key];
  if (url == null || url.isEmpty) {
    throw Exception('$key not found in environment variables.');
  }
  return url;
}
