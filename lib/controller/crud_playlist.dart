import 'dart:convert';

import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void addNewPlaylist(String name) async {
  final homeAlbumGridController = Get.find<HomeAlbumGridController>();
  homeAlbumGridController.isLoadingAddPlaylist.value = true;
  const String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist';

  try {
    await http.post(
      Uri.parse(url),
      body: {
        'method': 'create',
        'name_playlist': name,
      },
    );

    showRemoveAlbumToast('Playlist added to your library');
  } catch (e) {
    if (kDebugMode) {
      print('Error add new playlist: $e');
    }
  } finally {
    homeAlbumGridController.isLoadingAddPlaylist.value = false;
    homeAlbumGridController.initializeAlbum();
  }
}

Future<void> updatePlaylist(String id, String name) async {
  final homeAlbumGridController = Get.find<HomeAlbumGridController>();
  const String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist';

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'method': 'update',
        'name_playlist': name,
        'playlist_uid': id,
      },
    );

    if (response.body.isEmpty) {
      debugPrint('Error: Response body is empty');
      return;
    }

    final responseBody = jsonDecode(response.body);

    debugPrint('Response: $responseBody');
  } catch (e) {
    if (kDebugMode) {
      print('Error update playlist: $e');
    }
  } finally {
    homeAlbumGridController.initializeAlbum();
  }
}

void deletePlaylist(String id) async {
  final homeAlbumGridController = Get.find<HomeAlbumGridController>();

  homeAlbumGridController.removePlaylist(id);
  const String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist';

  try {
    await http.post(
      Uri.parse(url),
      body: {
        'method': 'delete',
        'playlist_uid': id,
      },
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error delete playlist: $e');
    }
  }
}
