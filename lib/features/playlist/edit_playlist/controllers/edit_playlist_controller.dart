import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EditPlaylistController extends GetxController{
  Future<void> editPlaylist(String id, String name) async {
    final homeAlbumGridController = Get.find<HomeController>();
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
        logError('Error: Response body is empty');
        return;
      }

      final responseBody = jsonDecode(response.body);

      logInfo('Response: $responseBody');
    } catch (e) {
      logError('Error update playlist: $e');
    } finally {
      homeAlbumGridController.initializeAlbum();
    }
  }
}