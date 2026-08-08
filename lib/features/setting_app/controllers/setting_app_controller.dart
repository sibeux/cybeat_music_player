import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:get/get.dart';

class SettingAppController extends GetxController {
  final AlbumService albumService = Get.find();
  bool get isSimpleMode => albumService.isSimpleMode.value;

  void toggleSimpleMode(bool value) {
    albumService.toggleSimpleMode(value);
  }
}
