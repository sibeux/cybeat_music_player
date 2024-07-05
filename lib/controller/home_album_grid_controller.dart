import 'dart:convert';

import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/controller/sort_preferences_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

final sortPreferencesController = Get.put(SortPreferencesController());

class HomeAlbumGridController extends GetxController {
  var children = RxList([]);
  var selectedAlbum = RxList<Playlist?>([]);
  var isTapped = false.obs;
  var jumlahPin = 0.obs;
  var isLoading = true.obs;
  var alphabeticalList = RxList<Playlist>([]);
  var recentsList = RxList<Playlist>([]);

  // diakses oleh splash_home_screen.dart
  var initiateAlbum = RxList<Playlist>([]);

  void updateChildren(List<Playlist> playlist) {
    children.value = List.generate(
      playlist.length,
      (index) => index,
    );

    selectedAlbum.value = List.generate(
      playlist.length,
      (index) => playlist[index],
    );

    alphabeticalList.value = List.generate(
      playlist.length,
      (index) => playlist[index],
    );

    alphabeticalList.sort((a, b) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    recentsList.value = List.generate(
      playlist.length,
      (index) => playlist[index],
    );

    recentsList.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    isTapped.value = !isTapped.value;
  }

  void pinAlbum(String uid) {
    final indexPin = jumlahPin.value;
    final index = selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final currentChild = children[index]; // Simpan elemen dari indeks index
    final currentAlbum =
        selectedAlbum[index]; // Simpan elemen dari indeks index
    children.removeAt(index); // Hapus elemen dari indeks index
    selectedAlbum.removeAt(index); // Hapus elemen dari indeks index
    children.insert(
        indexPin, currentChild); // Sisipkan kembali elemen ke indeks pin
    selectedAlbum.insert(
        indexPin, currentAlbum); // Sisipkan kembali elemen ke indeks pin

    setPinData(action: 'pin', uid: uid);
    jumlahPin.value++;
    isTapped.value = !isTapped.value;
  }

  void unpinAlbum(String uid) {
    final numPin = jumlahPin.value;
    final currentIndex = selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final alphabeticalIndex = alphabeticalList.indexWhere((playlist) => playlist.uid == uid);
    final recentsIndex = recentsList.indexWhere((playlist) => playlist.uid == uid);
    int normalIndex = 0;

    if (sortPreferencesController.sortValue == 'title') {
      normalIndex = alphabeticalIndex + numPin - 1;
    } else if (sortPreferencesController.sortValue == 'uid') {
      normalIndex = recentsIndex + numPin - 1;
    }

    // check current index
    final currentChild =
        children[currentIndex];
    final currentAlbum =
        selectedAlbum[currentIndex];

    // remove data from current index
    children.removeAt(currentIndex);
    selectedAlbum.removeAt(currentIndex);

    // insert data to normal index
    children.insert(normalIndex, currentChild);
    selectedAlbum.insert(
        normalIndex, currentAlbum);

    setPinData(action: 'unpin', uid: uid);
    jumlahPin.value--;
    isTapped.value = !isTapped.value;
  }

  Future<void> setPinData({required String action, required String uid}) async {
    String url = '';

    switch (action) {
      case 'pin':
        url =
            'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/pin_playlist.php?action=pin&uid=$uid';
        break;
      case 'unpin':
        url =
            'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/pin_playlist.php?action=unpin&uid=$uid';
        break;
      default:
        break;
    }

    try {
      await http.post(Uri.parse(url));
    } catch (e) {
      if (kDebugMode) {
        print('Error set pin: $e');
      }
    }
  }

  Future<void> initializeAlbum(String sort) async {
    jumlahPin.value = 0;
    isLoading.value = true;

    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?sort=$sort';

    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    try {
      final response = await http.post(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));

      final List<dynamic> listData = json.decode(response.body);
      final List<dynamic> apiData = json.decode(apiResponse.body);

      final list = listData.map((item) {
        jumlahPin.value =
            item['pin'] == 'true' ? jumlahPin.value + 1 : jumlahPin.value;

        return Playlist(
          uid: item['uid'],
          title: capitalizeEachWord(item['name']),
          image: regexGdriveLink(item['image'], apiData[0]['gdrive_api']),
          type: capitalizeEachWord(item['type']),
          pin: item['pin'],
          datePin: item['date_pin'] ?? '',
          date: item['date'],
        );
      }).toList();

      // ini mesti harus ada
      updateChildren(list);

      initiateAlbum.value = list;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    } finally {
      // ini tetap dieksekusi baik berhasil atau gagal
      isLoading.value = false;
    }
  }

  String regexGdriveLink(String url, String key) {
    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      return 'https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key';
    } else if (url.contains('www.googleapis.com')) {
      final regExp = RegExp(r'files\/([a-zA-Z0-9_-]+)\?');
      final match = regExp.firstMatch(url);
      return "https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key";
    } else {
      return url;
    }
  }
}
