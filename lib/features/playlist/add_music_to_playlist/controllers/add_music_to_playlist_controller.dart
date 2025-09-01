import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music_playlist.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddMusicToPlaylistController extends GetxController {
  final AlbumService albumService = Get.find<AlbumService>();
  var textController = TextEditingController();
  var textValue = ''.obs;

  var listMusicOnPlaylist = RxList<MusicPlaylist>([]);
  var savedInMusicList = RxList<String>([]);
  var newAddedMusic = RxList<String>([]);

  var isTyping = false.obs;
  var isKeybordFocus = false.obs;
  var searchBarTapped = false.obs;
  var isLoadingGetMusicOnPlaylist = false.obs;
  var isLoadingUpdateMusicOnPlaylist = false.obs;
  var isLoadingAddPlaylist = false.obs;

  bool get isHomeLoading => albumService.isHomeLoading.value;
  RxList<Playlist> get playlistCreatedList => albumService.playlistCreatedList;

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    update();
  }

  void tapSearchBar(bool value) {
    searchBarTapped.value = value;
  }

  void tapAddMusicToPlaylist(String idPlaylist) {
    newAddedMusic.add(idPlaylist);
  }

  void tapRemoveMusicFromPlaylist(String idPlaylist) {
    newAddedMusic.remove(idPlaylist);
  }

  void clearAll() {
    newAddedMusic.clear();
  }

  Future<void> getMusicOnPlaylist({required String idMusic}) async {
    isLoadingGetMusicOnPlaylist.value = true;

    String endpoint = dotenv.env['MUSIC_PLAYLIST_API_URL'] ?? '';
    String url = '$endpoint?id_music=$idMusic&method=get_music_on_playlist';
    try {
      final response = await http.get(Uri.parse(url));
      final List<dynamic> listData = json.decode(response.body);

      if (listData.isNotEmpty) {
        final list = listData.map((item) {
          savedInMusicList.add(item['id_playlist']);
          newAddedMusic.add(item['id_playlist']);
          return MusicPlaylist(
            uidMusicPlaylist: item['id_playlist_music'],
            uidMusic: item['id_music'],
            uidPlaylist: item['id_playlist'],
            dateAdded: item['date_add_music_playlist'],
          );
        }).toList();
        listMusicOnPlaylist.value = list;
      } else {
        listMusicOnPlaylist.value = [];
      }
    } catch (e) {
      logError('Error getMusicOnPlaylist: $e');
    } finally {
      isLoadingGetMusicOnPlaylist.value = false;
    }
  }

  Future<void> updateMusicOnPlaylist({
    required String idMusic,
    required AudioStateController audioState,
  }) async {
    isLoadingUpdateMusicOnPlaylist.value = true;

    String url = dotenv.env['MUSIC_PLAYLIST_API_URL'] ?? '';
    // Ini adalah ID playlist, bukan ID music.
    // Menghitung perbedaan.
    Set<String> setStrSaved = savedInMusicList.toSet();
    Set<String> setStrAdded = newAddedMusic.toSet();

    Set<int> setSaved = setStrSaved.map((e) => int.parse(e)).toSet();
    Set<int> setAdded = setStrAdded.map((e) => int.parse(e)).toSet();

    // NewAdded dan Savedin itu awalnya sama, sehingga kita bisa mencari-
    // perbedaan antara keduanya. Tinggal cari mana yang beda.

    // Cek => Yang ada di saved, tapi tidak ada di added.
    List<int> toRemove = setSaved
        .difference(setAdded)
        .toList(); // Lagu yang harus dihapus dari playlist
    // Cek => Yang ada di added, tapi tidak ada di saved.
    List<int> toAdd = setAdded
        .difference(setSaved)
        .toList(); // Lagu yang harus ditambahkan ke playlist

    // Cek apakah toRemove dan toAdd kosong.
    // Jika kosong, maka tidak perlu melakukan request ke server.
    // Karena tidak ada perubahan yang terjadi.
    if (toRemove.isEmpty && toAdd.isEmpty) {
      isLoadingUpdateMusicOnPlaylist.value = false;
      Get.back();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Pastikan JSON
        body: jsonEncode({
          'id_music': idMusic,
          'to_add':
              toAdd, // Tidak perlu `json.encode()`, karena `jsonEncode()` otomatis menangani List
          'to_remove': toRemove,
          'method': 'update_music_on_playlist',
        }),
      );

      if (response.body.isEmpty) {
        logError('Error: Response body is empty');
        return;
      }

      final responseBody = jsonDecode(response.body);
      logInfo('Response updateMusicOnPlaylist: $responseBody');

      if (responseBody['status'] == 'success') {
        if (toAdd.isNotEmpty && toRemove.isNotEmpty) {
          showRemoveAlbumToast('Music has been updated on the playlist');
        } else if (toAdd.isNotEmpty) {
          showRemoveAlbumToast('Music has been added to the playlist');
        } else if (toRemove.isNotEmpty) {
          showRemoveAlbumToast('Music has been removed from the playlist');
        }
      } else {
        logError('Error updateMusicOnPlaylist: $responseBody');
      }
    } catch (e) {
      logError('Error updateMusicOnPlaylist: $e');
    } finally {
      isLoadingUpdateMusicOnPlaylist.value = false;
      // Jika musik dihapus dari playlist, maka kita perlu menghapus
      // musik tersebut dari AZListView.
      final musicPlayerController = Get.find<MusicPlayerController>();
      if (toRemove.contains(
          int.parse(musicPlayerController.currentActivePlaylist.value!.uid))) {
        // Hentikan musik dan bersihkan queue.
        // Harus ada ini agar azlistview di-rebuild.
        // Bagian ini berfungsi untuk fetch ulang data list musik dari API.
        audioState.clear();
        musicPlayerController.killMusic();
        audioState.init(musicPlayerController.currentActivePlaylist.value!);
        musicPlayerController.setActivePlaylist(
            musicPlayerController.currentActivePlaylist.value!);

        // Baru setelah di-fetch, azlist di-rebuild pakai ini.
        final musicDownloadController = Get.find<MusicDownloadController>();
        musicDownloadController.rebuildDelete.value =
            !musicDownloadController.rebuildDelete.value;
      }
      Get.back();
    }
  }

  bool get isTypingValue => isTyping.value;
}
