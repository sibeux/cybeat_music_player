import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAlbumController extends GetxController {
  final AlbumService albumService = Get.find<AlbumService>();
  final controller = TextEditingController();
  var isTyping = false.obs;
  var textValue = ''.obs;
  var isKeybordFocus = false.obs;
  var filteredAlbum = RxList<Album?>([]);
  var isSearch = false.obs;

  void onTyping(String value) {
    isTyping.value = value.isNotEmpty;
    update();
  }

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    filterAlbum(value);
    update();
  }

  void filterAlbum(String value) {
    final results = albumService.selectedAlbum
        .where((album) =>
            album!.title.toLowerCase().contains(value.toLowerCase()) ||
            album.type.toLowerCase().contains(value.toLowerCase()) ||
            album.author.toLowerCase().contains(value.toLowerCase()))
        .toList();
    filteredAlbum.value = results;
    isSearch.value = !isSearch.value;
    update();
  }

  void openAlbum(
      {required Album album,
      required MusicPlayerController musicPlayerController}) {
    musicPlayerController.openAlbum(album: album);
  }

  String get getTextValue => textValue.value;

  bool get isTypingValue => isTyping.value;
}
