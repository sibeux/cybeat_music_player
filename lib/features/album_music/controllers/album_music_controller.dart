import 'package:cybeat_music_player/common/utils/toast.dart';
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
  void getToAddAllMusicToPlaylistScreen(){
    if (initAlbumLoading.value) {
      showRemoveAlbumToast('Wait a moment...');
    } else if (audioStateController.isAlbumEmpty.value) {
      showRemoveAlbumToast('Album is empty');
    } else {
      Get.toNamed("/add_all_music_to_playlist");
    }
  }
}
