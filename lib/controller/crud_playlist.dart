import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void addNewPlaylist(String name) async {
  final homeAlbumGridController = Get.put(HomeAlbumGridController());
  String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist?action=create&playlist_name=$name';

  try {
    await http.post(
      Uri.parse(url),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error add new playlist: $e');
    }
  } finally {
    homeAlbumGridController.initializeAlbum();
  }
}

void deletePlaylist(String id) async {
  final homeAlbumGridController = Get.put(HomeAlbumGridController());

  homeAlbumGridController.removePlaylist(id);
  String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist?action=delete&playlist_uid=$id';

  try {
    await http.post(
      Uri.parse(url),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error delete playlist: $e');
    }
  }
}
