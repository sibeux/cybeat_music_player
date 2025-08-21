import 'dart:convert';

import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/models/filter_item.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumService extends GetxService {
  // Ini adalah daftar list yang akan ditampilkan di home screen.
  var initiateAlbum = RxList<Playlist>([]); // diakses oleh home_screen.dart
  var allAlbumList = RxList<Playlist>([]); // Semua album yang ada
  var alphabeticalList =
      RxList<Playlist>([]); // Semua album diurutkan berdasarkan judul
  var recentsList =
      RxList<Playlist>([]); // Semua album diurutkan berdasarkan tanggal terbaru
  var onlyCategoryList =
      RxList<Playlist>([]); // Hanya album yang bertipe category
  var onlyAlbumList = RxList<Playlist>([]); // Hanya album yang bertipe 'album'
  // Ini adalah daftar playlist yang dibuat oleh user.
  var playlistCreatedList =
      RxList<Playlist>([]); // diakses oleh music_playlist_screen.dart
  var gdriveApiKeyList = RxList<dynamic>([]);

  var allAlbumChildren = RxList([]);
  var selectedAlbum = RxList<Playlist?>([]);

  var isHomeLoading = false.obs;

  // ============================== homeSortPreferencesController ==============================
  final homeSortPreferences = ''.obs;
  final isTapHomeSort = false.obs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // =============================== homeFilterAlbumController ==============================
  var initialFilter = RxList<FilterItem>(
    [
      FilterItem(filter: 'playlist', text: 'Playlist'),
      FilterItem(filter: 'album', text: 'Album'),
      FilterItem(filter: 'category', text: 'Category'),
    ],
  );

  var generateFilter = RxList<FilterItem>(
    [
      FilterItem(filter: 'playlist', text: 'Playlist'),
      FilterItem(filter: 'album', text: 'Album'),
      FilterItem(filter: 'category', text: 'Category'),
    ],
  );

  var filterChildren = RxList<int>([0, 1, 2]);
  var homeSelectedFilter = ''.obs;

  var jumlahPin = 0.obs;
  var albumCountGrid = 3.obs;

  var fourCoverCategory = RxList<dynamic>([]);
  var fourCoverPlaylist = RxList<dynamic>([]);

  Future<void> initializeAlbum() async {
    isHomeLoading.value = true;
    jumlahPin.value = 0;

    String sort = sortValue;
    String filter = getSelectedFilter;

    const String endpoint =
        "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist";
    String url = '$endpoint?sort=$sort&filter=$filter';
    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api';

    try {
      final response = await http.post(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));
      gdriveApiKeyList.value = json.decode(apiResponse.body);
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

      final list = listData.map((item) {
        jumlahPin.value =
            item['pin'] == 'true' ? jumlahPin.value + 1 : jumlahPin.value;

        return Playlist(
          uid: item['uid'],
          title: capitalizeEachWord(item['name']),
          image: item['image'] == null
              ? ''
              : regexGdriveHostUrl(
                  url: item['image'],
                  listApiKey: gdriveApiKeyList,
                  isAudio: false,
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
      updateAllAlbumChildren(list);
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
      logSuccess('Successfully initialized album with ${list.length} items');
    } catch (e, st) {
      logError(
          'Error initializeAlbum home album grid controller: $e. Stacktrace: $st');
    } finally {
      isHomeLoading.value = false;
    }
  }

  void updateAllAlbumChildren(List<Playlist> playlist) {
    allAlbumChildren.value = List.generate(
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
  }

  void pinAlbum(String uid) {
    final indexPin = jumlahPin.value;
    final index = selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final currentChild =
        allAlbumChildren[index]; // Simpan elemen dari indeks index
    final currentAlbum =
        selectedAlbum[index]; // Simpan elemen dari indeks index

    allAlbumChildren.removeAt(index); // Hapus elemen dari indeks index
    selectedAlbum.removeAt(index); // Hapus elemen dari indeks index

    allAlbumChildren.insert(
        indexPin, currentChild); // Sisipkan kembali elemen ke indeks pin
    selectedAlbum.insert(
        indexPin, currentAlbum); // Sisipkan kembali elemen ke indeks pin

    setPinData(action: 'pin', uid: uid);
    jumlahPin.value++;
  }

  void unpinAlbum(String uid) {
    final currentIndex =
        selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final alphabeticalIndex =
        alphabeticalList.indexWhere((playlist) => playlist.uid == uid);
    final recentsIndex =
        recentsList.indexWhere((playlist) => playlist.uid == uid);
    int normalIndex = 0;

    if (sortValue == 'title') {
      normalIndex = getNearestindex(alphabeticalIndex, 'title');
    } else if (sortValue == 'uid') {
      normalIndex = getNearestindex(recentsIndex, 'uid');
    }

    // check current index
    final currentChild = allAlbumChildren[currentIndex];
    final currentAlbum = selectedAlbum[currentIndex];

    // remove data from current index
    allAlbumChildren.removeAt(currentIndex);
    selectedAlbum.removeAt(currentIndex);

    // insert data to normal index
    allAlbumChildren.insert(normalIndex, currentChild);
    selectedAlbum.insert(normalIndex, currentAlbum);

    setPinData(action: 'unpin', uid: uid);
    jumlahPin.value--;
  }

  Future<bool> setPinData({required String action, required String uid}) async {
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
      return true;
    } catch (e) {
      logError('Error set pin: $e');
      return false;
    }
  }

  Future<bool> updateLastPlayedAlbum(String uid) async {
    // Method untuk update playlist terakhir yang diputar.
    String sort = sortValue;
    final indexPin = jumlahPin.value;
    final index = selectedAlbum.indexWhere((playlist) => playlist?.uid == uid);
    final currentChild = allAlbumChildren[index];
    final currentAlbum = selectedAlbum[index];

    await Future.delayed(const Duration(milliseconds: 300));

    if (sort == 'uid' && currentAlbum?.pin == 'false') {
      allAlbumChildren.removeAt(index);
      selectedAlbum.removeAt(index);
      allAlbumChildren.insert(indexPin, currentChild);
      selectedAlbum.insert(indexPin, currentAlbum);
      return true;
    } else {
      return false;
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
      logError('Error getSumFavoriteSong: $e');
    }

    return listData[0]['count_favorite'];
  }

  Future<List> getSumCategorySong() async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist?count_category=uid';

    List<dynamic> listData = [];

    try {
      final response = await http.post(Uri.parse(url));
      listData = json.decode(response.body);
    } catch (e) {
      logError('Error getSumCategorySong: $e');
    }

    return listData;
  }

  Future<void> getFourCoverAlbum(
      {required String method, required String type}) async {
    List<dynamic> responseBody = [];

    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/four_cover_album?method=$method';

    try {
      final response = await http.post(Uri.parse(url));
      responseBody = json.decode(response.body);

      if (responseBody.isEmpty) {
        logError('No data found for four cover album of type: $type');
        return;
      }

      final List<dynamic> formattedImageUrl = responseBody.map((item) {
        return {
          'playlist_uid': item['playlist_uid'],
          'cover_1': item['cover_1'] == null
              ? null
              : regexGdriveHostUrl(
                  url: item['cover_1'],
                  listApiKey: gdriveApiKeyList,
                  isAudio: false,
                ),
          'cover_2': item['cover_2'] == null
              ? null
              : regexGdriveHostUrl(
                  url: item['cover_2'],
                  listApiKey: gdriveApiKeyList,
                  isAudio: false,
                ),
          'cover_3': item['cover_3'] == null
              ? null
              : regexGdriveHostUrl(
                  url: item['cover_3'],
                  listApiKey: gdriveApiKeyList,
                  isAudio: false,
                ),
          'cover_4': item['cover_4'] == null
              ? null
              : regexGdriveHostUrl(
                  url: item['cover_4'],
                  listApiKey: gdriveApiKeyList,
                  isAudio: false,
                ),
          'total_non_null_cover': item['total_non_null_cover']
        };
      }).toList();

      if (type == 'category') {
        fourCoverCategory.value = formattedImageUrl;
      } else if (type == 'playlist') {
        fourCoverPlaylist.value = formattedImageUrl;
      }
    } catch (e) {
      logError('Error getFourCoverAlbum: $e');
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

    allAlbumChildren.removeAt(index);
    selectedAlbum.removeAt(index);
    playlistCreatedList.removeAt(indexPlaylist);
  }

  void changeLayoutGrid() {
    if (albumCountGrid.value == 3) {
      albumCountGrid.value = 1;
    } else {
      albumCountGrid.value = 3;
    }
  }

  // ============================== homeFilterAlbumController ==============================

  void onTapFilter({required String filter}) {
    var index =
        generateFilter.indexWhere((element) => element.filter == filter);

    final currentChild = filterChildren[index];
    final currentFilter = generateFilter[index];
    filterChildren.removeAt(index);
    generateFilter.removeAt(index);
    filterChildren.insert(0, currentChild);
    generateFilter.insert(0, currentFilter);

    filterChildren.insert(0, 4);
    generateFilter.insert(0, FilterItem(filter: 'cancel', text: 'Cancel'));

    homeSelectedFilter.value = filter;
  }

  void onResetFilter() {
    var initialIndex = initialFilter
        .indexWhere((element) => element.filter == homeSelectedFilter.value);
    var currentIndex = generateFilter
        .indexWhere((element) => element.filter == homeSelectedFilter.value);

    final currentChild = filterChildren[currentIndex];
    final currentFilter = generateFilter[currentIndex];
    filterChildren.removeAt(currentIndex);
    generateFilter.removeAt(currentIndex);

    filterChildren.removeAt(0);
    generateFilter.removeAt(0);

    filterChildren.insert(initialIndex, currentChild);
    generateFilter.insert(initialIndex, currentFilter);

    homeSelectedFilter.value = '';
  }

  String get getSelectedFilter => homeSelectedFilter.value;

  // ========================== homeSortPreferencesController ==========================

  Future<void> saveSortBy(String value) async {
    final SharedPreferences prefs = await _prefs;
    isTapHomeSort.value = !isTapHomeSort.value;

    switch (value) {
      case 'Recents':
        homeSortPreferences.value = 'uid';
        prefs.setString('sort', 'uid');
        break;
      case 'Alphabetical':
        homeSortPreferences.value = 'title';
        prefs.setString('sort', 'title');
        break;
    }
  }

  Future<void> getSortBy() async {
    final SharedPreferences prefs = await _prefs;
    final sort = prefs.getString('sort') ?? 'uid';
    homeSortPreferences.value = sort;
  }

  String get sortValue => homeSortPreferences.value;

  Future<void> editPlaylist(String id, String name) async {
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
      initializeAlbum();
    }
  }
}
