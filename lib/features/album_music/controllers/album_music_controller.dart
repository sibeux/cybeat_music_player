import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:get/get.dart';

class AlbumMusicController extends GetxController {
  void updateLastPlayedAlbum(String uid) async {
    final AlbumService albumService = Get.find();
    await albumService.updateLastPlayedAlbum(uid);
  }
}
