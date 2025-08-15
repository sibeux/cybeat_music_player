import 'package:cybeat_music_player/components/colorize_terminal.dart';
import 'package:http/http.dart' as http;

void setRecentsMusic(String? id) async {
  String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/recents_music?_id=$id';

  try {
    await http.post(
      Uri.parse(url),
    );
  } catch (e) {
      logError('Error set recents music: $e');
  }
}
