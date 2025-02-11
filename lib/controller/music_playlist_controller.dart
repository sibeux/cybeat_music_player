import 'dart:convert';

import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/models/music_playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MusicPlaylistController extends GetxController {
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

  Future<void> getMusicOnPlaylist({required String idMusic}) async {
    isLoadingGetMusicOnPlaylist.value = true;

    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/music_playlist.php?id_music=$idMusic&method=get_music_on_playlist';
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
      debugPrint('Error getMusicOnPlaylist: $e');
    } finally {
      isLoadingGetMusicOnPlaylist.value = false;
    }
  }

  Future<void> updateMusicOnPlaylist({required String idMusic}) async {
    isLoadingUpdateMusicOnPlaylist.value = true;

    const url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/music_playlist';

    // Menghitung perbedaan
    Set<String> setStrSaved = savedInMusicList.toSet();
    Set<String> setStrAdded = newAddedMusic.toSet();

    Set<int> setSaved = setStrSaved.map((e) => int.parse(e)).toSet();
    Set<int> setAdded = setStrAdded.map((e) => int.parse(e)).toSet();

    List<int> toRemove =
        setSaved.difference(setAdded).toList(); // Lagu yang harus dihapus
    List<int> toAdd =
        setAdded.difference(setSaved).toList(); // Lagu yang harus ditambahkan
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
        debugPrint('Error: Response body is empty');
        return;
      }

      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 'success') {
        Get.back();
        showRemoveAlbumToast('Music has been added to the playlist');
      } else {
        debugPrint('Error updateMusicOnPlaylist: $responseBody');
      }
    } catch (e) {
      debugPrint('Error updateMusicOnPlaylist: $e');
    } finally {
      isLoadingUpdateMusicOnPlaylist.value = false;
    }
  }

  bool get isTypingValue => isTyping.value;
}
