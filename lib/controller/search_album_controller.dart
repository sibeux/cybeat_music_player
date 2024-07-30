import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAlbumController extends GetxController {
  final controller = TextEditingController();
  final HomeAlbumGridController homeAlbumGridController = Get.find();
  var isTyping = false.obs;
  var textValue = ''.obs;
  var isKeybordFocus = false.obs;
  var filteredAlbum = RxList<Playlist?>([]);
  var isSearch = false.obs;

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    filterAlbum(value);
    update();
  }

  void filterAlbum(String value) {
    final results = homeAlbumGridController.selectedAlbum
        .where((album) =>
            album!.title.toLowerCase().contains(value.toLowerCase()) ||
            album.type.toLowerCase().contains(value.toLowerCase()) ||
            album.author.toLowerCase().contains(value.toLowerCase()))
        .toList();

    filteredAlbum.value = results;
    isSearch.value = !isSearch.value;
    update();
  }

  get getTextValue => textValue.value;

  get isTypingValue => isTyping.value;
}
