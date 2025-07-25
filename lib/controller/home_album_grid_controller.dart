import 'dart:convert';

import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/components/url_formatter.dart';
import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:cybeat_music_player/controller/sort_preferences_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final sortPreferencesController = Get.put(SortPreferencesController());
final filterAlbumController = Get.find<FilterAlbumController>();

class HomeAlbumGridController extends GetxController {
  var children = RxList([]);
  var selectedAlbum = RxList<Playlist?>([]);

  var jumlahPin = 0.obs;
  var jumlahDitampilkan = 15.obs;
  var countGrid = 3.obs;

  var isLoading = true.obs;
  var isTapped = false.obs;
  // Ini seharusnya ada di controller crud_playlist, tapi karena-
  // crud_playlist bukan controller, maka isLoading dipindahkan ke sini. (Malas ubah) :v
  var isLoadingAddPlaylist = false.obs;

  var alphabeticalList =
      RxList<Playlist>([]); // Semua album diurutkan berdasarkan judul
  var recentsList =
      RxList<Playlist>([]); // Semua album diurutkan berdasarkan terbaru
  var allAlbumList = RxList<Playlist>([]); // Semua album yang ada
  var onlyCategoryList =
      RxList<Playlist>([]); // Hanya album yang bertipe category
  var onlyAlbumList = RxList<Playlist>([]); // Hanya album yang bertipe album
  // Ini adalah daftar playlist yang dibuat oleh user.
  var playlistCreatedList =
      RxList<Playlist>([]); // diakses oleh music_playlist_screen.dart

  // Ini adalah daftar list yang akan ditampilkan di home screen.
  var initiateAlbum = RxList<Playlist>([]); // diakses oleh home_screen.dart

  var fourCoverCategory = RxList<dynamic>([]);
  var fourCoverPlaylist = RxList<dynamic>([]);

  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));
    initializeAlbum();
    // if failed,use refreshFailed()
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    // monitor network fetch
    jumlahDitampilkan.value = jumlahDitampilkan.value + 18;
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    refreshController.loadComplete();
  }

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
    final currentIndex =
        selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final alphabeticalIndex =
        alphabeticalList.indexWhere((playlist) => playlist.uid == uid);
    final recentsIndex =
        recentsList.indexWhere((playlist) => playlist.uid == uid);
    int normalIndex = 0;

    if (sortPreferencesController.sortValue == 'title') {
      normalIndex = getNearestindex(alphabeticalIndex, 'title');
    } else if (sortPreferencesController.sortValue == 'uid') {
      normalIndex = getNearestindex(recentsIndex, 'uid');
    }

    // check current index
    final currentChild = children[currentIndex];
    final currentAlbum = selectedAlbum[currentIndex];

    // remove data from current index
    children.removeAt(currentIndex);
    selectedAlbum.removeAt(currentIndex);

    // insert data to normal index
    children.insert(normalIndex, currentChild);
    selectedAlbum.insert(normalIndex, currentAlbum);

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

  void recentPlaylistUpdate(String uid) async {
    String sort = sortPreferencesController.sortValue;
    final indexPin = jumlahPin.value;
    final index = selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final currentChild = children[index];
    final currentAlbum = selectedAlbum[index];

    await Future.delayed(const Duration(milliseconds: 300));

    if (sort == 'uid' && currentAlbum?.pin == 'false') {
      children.removeAt(index);
      selectedAlbum.removeAt(index);
      children.insert(indexPin, currentChild);
      selectedAlbum.insert(indexPin, currentAlbum);

      isTapped.value = !isTapped.value;
    }
  }

  Future<void> initializeAlbum() async {
    jumlahPin.value = 0;
    jumlahDitampilkan.value = 15;
    isLoading.value = true;

    String sort = sortPreferencesController.sortValue;
    String filter = filterAlbumController.getSelectedFilter;

    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?sort=$sort&filter=$filter';

    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    try {
      final response = await http.post(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));
      final jumlahFavorite = await getSumFavoriteSong();
      final listJumlahCategory = await getSumCategorySong();
      await getFourCoverAlbum(method: 'four_cover_category', type: 'category');
      await getFourCoverAlbum(method: 'four_cover_playlist', type: 'playlist');

      List jumlahCategory(String uid) {
        return listJumlahCategory
            .where((element) => element['uid'] == uid)
            .map((e) => e['type_count'])
            .toList();
      }

      String sumAllsong() {
        var sum = 0;
        for (var i = 0; i < listJumlahCategory.length; i++) {
          sum += int.parse(listJumlahCategory[i]['type_count']);
        }
        return NumberFormat("#,###", "id_ID").format(sum).toString();
      }

      String addDotNumb(int number) {
        return NumberFormat("#,###", "id_ID").format(number);
      }

      final List<dynamic> listData = json.decode(response.body);
      final List<dynamic> apiData = json.decode(apiResponse.body);

      final list = listData.map((item) {
        jumlahPin.value =
            item['pin'] == 'true' ? jumlahPin.value + 1 : jumlahPin.value;

        return Playlist(
          uid: item['uid'],
          title: capitalizeEachWord(item['name']),
          image: item['image'] == null
              ? ''
              : regexGdriveLink(
                  url: item['image'],
                  listApiKey: apiData,
                ),
          type: (item['type']).toString().capitalizeFirst!,
          author: item['type'] == 'album'
              ? capitalizeEachWord(item['author'])
              : item['type'] == 'favorite'
                  ? '$jumlahFavorite Songs'
                  : item['type'] == 'category'
                      ? item['uid'] == '481'
                          ? '${sumAllsong()} Songs'
                          : '${addDotNumb(int.parse(jumlahCategory(item['uid'])[0]))} ${int.parse(jumlahCategory(item['uid'])[0]) <= 1 ? 'Song' : 'Songs'}'
                      : capitalizeEachWord(item['author']),
          pin: item['pin'],
          datePin: item['date_pin'] ?? '',
          date: item['date'],
          editable: item['editable'],
        );
      }).toList();

      // ini mesti harus ada
      updateChildren(list);
      onlyAlbumList.value = list
          .where((playlist) => playlist.type.toLowerCase() == 'album')
          .toList();
      onlyCategoryList.value = list
          .where((playlist) => playlist.type.toLowerCase() == 'category')
          .toList();
      playlistCreatedList.value = list
          .where((playlist) => playlist.type.toLowerCase() == 'playlist')
          .toList();

      // Semua album yang ada dimasukkan ke dalam sini.
      initiateAlbum.value = list;
      allAlbumList.value = list;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    } finally {
      // ini tetap dieksekusi baik berhasil atau gagal
      isLoading.value = false;
    }
  }

  Future<String> getSumFavoriteSong() async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?count_favorite=true';

    List<dynamic> listData = [];

    try {
      final response = await http.post(Uri.parse(url));
      listData = json.decode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    return listData[0]['count_favorite'];
  }

  Future<List> getSumCategorySong() async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?count_category=uid';

    List<dynamic> listData = [];

    try {
      final response = await http.post(Uri.parse(url));
      listData = json.decode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    return listData;
  }

  Future<void> getFourCoverAlbum(
      {required String method, required String type}) async {
    List<dynamic> fourCover = [];

    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/four_cover_album?method=$method';

    try {
      final response = await http.post(Uri.parse(url));
      fourCover = json.decode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    if (type == 'category') {
      fourCoverCategory.value = fourCover;
    } else if (type == 'playlist') {
      fourCoverPlaylist.value = fourCover;
    }
  }

  int getNearestindex(int filterIndex, String filter) {
    final numPin = jumlahPin.value;
    var selisih = selectedAlbum.length - 1;
    var isNegative = false;
    var index = 0;

    for (var i = numPin; i < selectedAlbum.length; i++) {
      if (filter == 'title') {
        final replacementIndex = alphabeticalList
            .indexWhere((playlist) => playlist.uid == selectedAlbum[i]?.uid);
        if ((replacementIndex - filterIndex).abs() < selisih) {
          selisih = (replacementIndex - filterIndex).abs();
          isNegative = filterIndex - replacementIndex < 0;
          index = i;
        }
      } else if (filter == 'uid') {
        final replacementIndex = recentsList
            .indexWhere((playlist) => playlist.uid == selectedAlbum[i]?.uid);
        if ((replacementIndex - filterIndex).abs() < selisih) {
          selisih = (replacementIndex - filterIndex).abs();
          isNegative = filterIndex - replacementIndex < 0;
          index = i;
        }
      }
    }

    return isNegative ? index - 1 : index;
  }

  void removePlaylist(String uid) {
    // Cari index dari playlist yang akan dihapus di dalam seluruh album/playlist.
    final index = selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    // Cari index dari playlist yang akan dihapus di dalam list playlist.
    final indexPlaylist =
        playlistCreatedList.indexWhere((playlist) => playlist.uid == uid);

    children.removeAt(index);
    selectedAlbum.removeAt(index);
    playlistCreatedList.removeAt(indexPlaylist);

    isTapped.value = !isTapped.value;
  }

  void changeLayoutGrid() {
    if (countGrid.value == 3) {
      countGrid.value = 1;
    } else {
      countGrid.value = 3;
    }
  }
}
