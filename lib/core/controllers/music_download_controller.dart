import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicDownloadController extends GetxController {
  var musicOfflineList = RxList<dynamic>([]);
  var rebuildDelete = false.obs;
  var dataProgressDownload = <String, Map<String, dynamic>>{}.obs;

  final musicPlayerController = Get.find<MusicPlayerController>();

  void goOfflineScreen({
    required AudioStateController audioState,
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

    if (musicPlayerController.currentActivePlaylist.value?.title !=
            playlist.title ||
        musicPlayerController.currentActivePlaylist.value?.title == "") {
      audioState.clear();
      musicPlayerController.pauseMusic();
      musicPlayerController.clearCurrentMediaItem();
      audioState.init(playlist);
      musicPlayerController.setActivePlaylist(playlist);
    }

    Get.toNamed('/album_music', id: 1);
  }

  Future<void> checkListTempDir() async {
    // getTemporaryDirectory(); ini buat cache file.
    // final directory = await getTemporaryDirectory();
    // Kita pakai getApplicationDocumentsDirectory(); biar disimpan di direktori aplikasi.
    final directory = await getApplicationDocumentsDirectory();
    final appDirPath = directory.path;

    // Mendapatkan daftar file yang ada di direktori sementara
    final appDir = Directory(appDirPath);
    final files = appDir.listSync();

    // Mencetak nama file yang ada di dalamnya
    for (var file in files) {
      // logger.d('File found: ${file.path}');
      logInfo('File found: ${file.path}');
    }
  }

  Future<void> downloadOfflineMusic(MediaItem mediaItem) async {
    try {
      // getTemporaryDirectory(); ini buat cache file.
      // final directory = await getTemporaryDirectory();
      // Kita pakai getApplicationDocumentsDirectory(); biar disimpan di direktori aplikasi.
      final directory = await getApplicationDocumentsDirectory();
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
      logError("Error downloading song: $e");
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
    logSuccess("Song successfully downloaded and saved in $filePath");
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
    AudioStateController audioState,
  ) async {
    try {
      // Mendapatkan direktori sementara
      // getTemporaryDirectory(); ini buat cache file.
      // final directory = await getTemporaryDirectory();
      // Kita pakai getApplicationDocumentsDirectory(); biar disimpan di direktori aplikasi.
      final directory = await getApplicationDocumentsDirectory();
      final appDirPath = directory.path;

      final namefile = filePath.split('/').last;

      // Mendapatkan file dengan path yang diberikan
      final file = File('$appDirPath/$namefile');

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

        // Ini berfungsi untuk memperbarui daftar musik offline.
        // Karena di audiostate, daftar musik offline diambil dari {musicOfflineList.value}.
        // Jadi, kita perlu memperbarui nilai {musicOfflineList.value} agar UI terupdate.
        musicOfflineList.value = list.map((e) => e).toList();

        // Jika musik yang dihapus sedang diputar, hentikan pemutaran
        audioState.clear();
        musicPlayerController.pauseMusic();
        audioState.init(musicPlayerController.currentActivePlaylist.value!);
        musicPlayerController.setActivePlaylist(
            musicPlayerController.currentActivePlaylist.value!);

        // Untuk memberitahu bahwa musik sudah tidak ada di offline,
        // (Ikon centang downloaded hilang).
        mediaItem.extras!['is_downloaded'] = false;

        logError('File deleted: $filePath');
        showRemoveAlbumToast('Music has been deleted from offline');
        Get.back();
      } else {
        logError('File does not exist: $filePath');
      }
    } catch (e) {
      logError('Error deleting file: $e');
    } finally {
      // Ini dipakai agar musik di azlistview di-rebuild.
      rebuildDelete.value = !rebuildDelete.value;
    }
  }
}
