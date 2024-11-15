import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/controller/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicDownloadController extends GetxController {
  var musicOfflineList = RxList<dynamic>([]);
  var rebuildDelete = false.obs;
  var dataProgressDownload = <String, Map<String, dynamic>>{}.obs;

  void goOfflineScreen({
    required AudioState audioState,
    required PlayingStateController playingStateController,
    required BuildContext context,
  }) {
    Playlist playlist = Playlist(
      uid: 'offline',
      title: 'Offline Music',
      author: 'Nasrul Wahabi',
      date: 'no date',
      datePin: 'no date',
      editable: 'true',
      image: 'no image',
      pin: 'false',
      type: 'offline',
    );

    final playlistPlayController = Get.put(PlaylistPlayController());

    if (playlistPlayController.playlistTitleValue != playlist.title ||
        playlistPlayController.playlistTitleValue == "") {
      audioState.clear();
      playingStateController.pause();
      context.read<MusicState>().clear();
      audioState.init(playlist);
      playlistPlayController.onPlaylist(playlist);
    }

    Get.to(
      () => AzListMusicScreen(
        audioState: audioState,
      ),
      transition: Transition.leftToRightWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> checkListTempDir() async {
    final directory = await getTemporaryDirectory();
    final tempDirPath = directory.path;

    // Mendapatkan daftar file yang ada di direktori sementara
    final tempDir = Directory(tempDirPath);
    final files = tempDir.listSync();

    // Mencetak nama file yang ada di dalamnya
    for (var file in files) {
      logger.d('File found: ${file.path}');
    }
  }

  Future<void> downloadAndCacheMusic(MediaItem mediaItem) async {
    try {
      // Dapatkan direktori cache
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${mediaItem.extras!['music_id']}_${mediaItem.title}';

      dataProgressDownload[mediaItem.extras!['music_id']] = {
        'progress': 0.0,
      };

      // Unduh file dari URL dan simpan di path cache
      final dio = Dio();
      await dio.download(
        mediaItem.extras!['url'],
        filePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            final progress = count / total;
            dataProgressDownload[mediaItem.extras!['music_id']]?['progress'] =
                progress;
            dataProgressDownload.refresh(); // Agar UI terupdate
          }
        },
      );

      // Setelah file diunduh, simpan metadata di SharedPreferences atau SQLite
      await saveDownloadedSong(mediaItem, filePath);
    } catch (e) {
      logger.e("Error downloading song: $e");
    }
  }

  Future<void> saveDownloadedSong(MediaItem mediaItem, String filePath) async {
    // Menyimpan metadata (contohnya ID lagu dan path) ke SharedPreferences atau SQLite
    final prefs = await SharedPreferences.getInstance();
    final downloadedSongs = prefs.getStringList('downloadedSongs') ?? [];
    final uidDownloadedSongs = prefs.getStringList('uidDownloadedSongs') ?? [];

    final songId = mediaItem.extras!['music_id'];
    final title = mediaItem.title;
    final artist = mediaItem.artist;
    final album = mediaItem.album;
    final artUri = mediaItem.artUri;
    final favorite = mediaItem.extras!['favorite'];
    final isDownloaded = mediaItem.extras!['is_downloaded'];

    downloadedSongs.add(
        '$songId|$title|$artist|$album|$artUri|$favorite|$isDownloaded|$filePath');
    uidDownloadedSongs.add(songId);

    await prefs.setStringList('downloadedSongs', downloadedSongs);
    await prefs.setStringList('uidDownloadedSongs', uidDownloadedSongs);

    mediaItem.extras!['is_downloaded'] = true;

    showRemoveAlbumToast('Song downloaded successfully');

    dataProgressDownload.remove(mediaItem.extras!['music_id']);
    logger.d("Song successfully downloaded and saved in $filePath");
  }

  Future<void> getDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedSongs = prefs.getStringList('downloadedSongs') ?? [];

    await checkListTempDir();

    final list = downloadedSongs.map((songData) {
      final parts = songData.split('|');
      return {
        'id_music': parts[0],
        'title': parts[1],
        'artist': parts[2],
        'album': parts[3],
        'cover': parts[4],
        'favorite': parts[5],
        'is_downloaded': parts[6],
        'filePath': parts[7],
      };
    }).toList();

    musicOfflineList.value = list.map((e) => e).toList();
  }

  Future<void> deleteSpecificFile(
    String filePath,
    MediaItem mediaItem,
    AudioState audioState,
  ) async {
    try {
      final playingStateController = Get.find<PlayingStateController>();
      final playlistPlayController = Get.find<PlaylistPlayController>();

      // Mendapatkan direktori sementara
      final directory = await getTemporaryDirectory();
      final tempDirPath = directory.path;

      final namefile = filePath.split('/').last;

      // Mendapatkan file dengan path yang diberikan
      final file = File('$tempDirPath/$namefile');

      if (await file.exists()) {
        // Menghapus file jika ada
        await file.delete();

        final prefs = await SharedPreferences.getInstance();
        final downloadedSongs = prefs.getStringList('downloadedSongs') ?? [];
        final uidDownloadedSongs =
            prefs.getStringList('uidDownloadedSongs') ?? [];
        final songId = mediaItem.extras!['music_id'];

        // Cari dan hapus entri yang mengandung songId
        downloadedSongs.removeWhere((song) => song.startsWith('$songId|'));
        uidDownloadedSongs.removeWhere((uid) => uid == songId);

        // Simpan kembali daftar yang sudah diperbarui
        await prefs.setStringList('downloadedSongs', downloadedSongs);
        await prefs.setStringList('uidDownloadedSongs', uidDownloadedSongs);

        final list = downloadedSongs.map((songData) {
          final parts = songData.split('|');
          return {
            'id_music': parts[0],
            'title': parts[1],
            'artist': parts[2],
            'album': parts[3],
            'cover': parts[4],
            'favorite': parts[5],
            'is_downloaded': parts[6],
            'filePath': parts[7],
          };
        }).toList();

        musicOfflineList.value = list.map((e) => e).toList();

        Playlist playlist = Playlist(
          uid: 'offline',
          title: 'Offline Music',
          author: 'Nasrul Wahabi',
          date: 'no date',
          datePin: 'no date',
          editable: 'true',
          image: 'no image',
          pin: 'false',
          type: 'offline',
        );

        audioState.clear();
        playingStateController.pause();
        audioState.init(playlist);
        playlistPlayController.onPlaylist(playlist);

        mediaItem.extras!['is_downloaded'] = false;

        logger.d('File deleted: $filePath');
      } else {
        logger.e('File does not exist: $filePath');
      }
    } catch (e) {
      logger.e('Error deleting file: $e');
    } finally {
      rebuildDelete.value = !rebuildDelete.value;
    }
  }
}
