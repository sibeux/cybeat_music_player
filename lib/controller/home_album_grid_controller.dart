import 'dart:convert';

import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeAlbumGridController extends GetxController {
  var children = RxList([]);
  var selectedAlbum = RxList<Playlist?>([]);
  var isTapped = false.obs;
  var jumlahPin = 0.obs;

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

    jumlahPin.value++;
    isTapped.value = !isTapped.value;
  }

  Future<void> initializeAlbum(String sort) async {
    jumlahPin.value = 0;
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
