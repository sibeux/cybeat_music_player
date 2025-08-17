import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:get/get.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:http/http.dart' as http;

class DetailMusicController extends GetxController {
  final MusicPlayerController musicPlayerController = Get.find();
  final AudioStateController audioStateController = Get.find();
  MediaItem? get currentMediaItem => musicPlayerController.getCurrentMediaItem;
  get currentActivePlaylist =>
      musicPlayerController.currentActivePlaylist.value;
  get isAzlistviewScreenActive =>
      musicPlayerController.isAzlistviewScreenActive.value;
  get sampleRate => audioStateController.sampleRate.value;
  get bitsPerRawSample => audioStateController.bitsPerRawSample.value;
  get bitRate => audioStateController.bitRate.value;

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
