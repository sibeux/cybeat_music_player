import 'package:get/get.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:http/http.dart' as http;

class DetailMusicController extends GetxController{

void setfavorite(String? id, String? isFavorite) async {
  String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/favorite?_id=$id&_favorite=$isFavorite';

  try {
    await http.post(
      Uri.parse(url),
    );
  } catch (e, st) {
    logError('Error set favorite: $e, stack: $st');
  }
}
}