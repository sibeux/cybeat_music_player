import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditPlaylistController extends GetxController {
  final controller = TextEditingController();
  var isTyping = false.obs;
  var textValue = ''.obs;
  var isKeybordFocus = false.obs;
  final albumService = Get.find<AlbumService>();

  void onTyping(String value) {
    isTyping.value = value.isNotEmpty;
    update();
  }

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    update();
  }

  Future<void> editPlaylist(String id, String name) async {
    await albumService.editPlaylist(
      id,
      name,
    );
  }
}
