import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:get/get.dart';

class AlbumMusicController extends GetxController {
  final AudioStateController audioStateController = Get.find();
  RxBool get initAlbumLoading => audioStateController.initAlbumLoading;
  void updateLastPlayedAlbum(String uid) async {
    final AlbumService albumService = Get.find();
    await albumService.updateLastPlayedAlbum(uid);
  }
}
