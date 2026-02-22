import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/mappers/album_mapper.dart';
import 'package:cybeat_music_player/core/models/filter_item.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:cybeat_music_player/core/repositories/album_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';

class AlbumService extends GetxService {
  final AlbumRepository _albumRepository = AlbumRepository();
  // Ini adalah daftar list yang akan ditampilkan di home screen.
  var initiateAlbum = RxList<Album>([]); // diakses oleh home_screen.dart
  var allAlbumList = RxList<Album>([]); // Semua album yang ada
  var alphabeticalList =
      RxList<Album>([]); // Semua album diurutkan berdasarkan judul
  var recentsList =
      RxList<Album>([]); // Semua album diurutkan berdasarkan tanggal terbaru
  var onlyCategoryList = RxList<Album>([]); // Hanya album yang bertipe category
  var onlyAlbumList = RxList<Album>([]); // Hanya album yang bertipe 'album'
  // Ini adalah daftar playlist yang dibuat oleh user.
  var playlistCreatedList =
      RxList<Album>([]); // diakses oleh music_playlist_screen.dart
  var gdriveApiKeyList = RxList<dynamic>([]);

  var allAlbumChildren = RxList([]);
  var selectedAlbum = RxList<Album?>([]);

  var defaultAlbumColor = "ffffff".obs;

  var isHomeLoading = false.obs;
  // Use in setting app and album music screen
  var isSimpleMode = false.obs;

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

    // String sort = sortValue;
    // String filter = getSelectedFilter;

    String api = dotenv.env['GDRIVE_API_URL'] ?? 'Kunci API Tidak Ditemukan';

    try {
      final apiResponse = await http.get(Uri.parse(api));
      gdriveApiKeyList.value = json.decode(apiResponse.body);
      // final jumlahFavorite = await getSumFavoriteSong();
      // final listJumlahCategory = await getSumCategorySong();
      // await getFourCoverAlbum(method: 'four_cover_category', type: 'category');
      // await getFourCoverAlbum(method: 'four_cover_playlist', type: 'playlist');

      // List jumlahCategory(String uid) {
      //   return listJumlahCategory
      //       .where((element) => element['uid'] == uid)
      //       .map((e) => e['type_count'])
      //       .toList();
      // }

      // String sumAllsong() {
      //   var sum = 0;
      //   for (var i = 0; i < listJumlahCategory.length; i++) {
      //     sum += int.parse(listJumlahCategory[i]['type_count']);
      //   }
      //   return NumberFormat("#,###", "id_ID").format(sum).toString();
      // }

      // String addDotNumb(int number) {
      //   return NumberFormat("#,###", "id_ID").format(number);
      // }

      // Access the 'album' key inside the 'data' map
      final response = await _albumRepository.fetchAlbums();
      final dataMap = response['data'] as Map<String, dynamic>?;

      // Kumpulkan semua list menjadi satu.
      // pakai Spread Operator.
      final allRawData = [
        ...(dataMap?['album'] ?? []),
        ...(dataMap?['category'] ?? []),
        ...(dataMap?['playlist'] ?? []),
      ];

      // Map semuanya sekaligus
      final List<Album> list = allRawData.map((item) {
        final album = AlbumMapper.fromMap(
          item,
          currentPinCount: jumlahPin.value,
          gdriveApiKeyList: gdriveApiKeyList,
        );

        // Update jumlah pin secara reaktif jika perlu
        if (album.pin == 'true') jumlahPin.value++;

        return album;
      }).toList();

      // Distribusikan ke UI/State
      _updateLists(list);

      logSuccess('Successfully initialized album with ${list.length} items');
    } catch (e, st) {
      logError('Error initializeAlbum: $e. Stacktrace: $st');
    } finally {
      isHomeLoading.value = false;
    }
  }

  void _updateLists(List<Album> list) {
    updateAllAlbumChildren(list);
    initiateAlbum.value = list;
    allAlbumList.value = list;

    // Filtering dilakukan di sini agar lebih sentralistik
    onlyAlbumList.value =
        list.where((p) => p.type.toLowerCase() == 'album').toList();
    onlyCategoryList.value =
        list.where((p) => p.type.toLowerCase() == 'category').toList();
    playlistCreatedList.value =
        list.where((p) => p.type.toLowerCase() == 'playlist').toList();
  }

  void updateAllAlbumChildren(List<Album> album) {
    // Sort Master List berdasarkan Pin & Recents dulu
    // Supaya view default (selectedAlbum) itu yang paling relevan
    /***
     * Gunakan List.from(album): Daripada pakai List.generate, lebih singkat dan bersih menggunakan List.from(). 
     * Fungsinya sama, yaitu membuat salinan list baru agar saat alphabeticalList di-sort, 
     * list aslinya tidak ikut berubah (karena di Dart, list adalah reference).
     * ***/
    album.sort((a, b) {
      // Prioritaskan Pin
      if (a.pin == 'true' && b.pin == 'false') return -1;
      if (a.pin == 'false' && b.pin == 'true') return 1;

      // Bandingkan mana yang lebih baru antara playedAt atau createdAt untuk tiap album
      String timeA = a.playedAt.isAfter(a.createdAt) ? a.playedAt : a.createdAt;
      String timeB = b.playedAt.isAfter(b.createdAt) ? b.playedAt : b.createdAt;

      return timeB.compareTo(timeA); // Terbaru di atas
    });

    // Baru masukkan ke view-view spesifik
    allAlbumChildren.value = List.generate(album.length, (i) => i);

    // selectedAlbum sekarang otomatis punya urutan Pin di atas
    selectedAlbum.value = List.from(album);

    // View Alphabetical (Sort mandiri)
    alphabeticalList.value = List.from(album);
    alphabeticalList
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    // View Recents (Sort mandiri)
    recentsList.value = List.from(album);
    recentsList.sort((a, b) => b.playedAt.compareTo(a.playedAt));
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
    String playlistApi =
        dotenv.env['PIN_PLAYLIST_API_URL'] ?? 'Kunci API Tidak Ditemukan';
    String url = '';

    switch (action) {
      case 'pin':
        url = '$playlistApi?action=pin&uid=$uid';
        break;
      case 'unpin':
        url = '$playlistApi?action=unpin&uid=$uid';
        break;
      default:
        break;
    }

    try {
      final response = await http.post(Uri.parse(url));
      if (response.body.isEmpty) {
        logError('Error: Response body is empty');
        return false;
      }
      logInfo('Success set pin response: ${response.body}');
      return true;
    } catch (e, st) {
      logError('Error set pin: $e,$st');
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
    String playlistApi =
        dotenv.env['PLAYLIST_API_URL'] ?? 'Kunci API Tidak Ditemukan';
    String url = '$playlistApi?count_favorite=true';

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
    String playlistApi =
        dotenv.env['PLAYLIST_API_URL'] ?? 'Kunci API Tidak Ditemukan';
    String url = '$playlistApi?count_category=uid';

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
    String api = dotenv.env['FOURCOVER_API_URL'] ?? 'Kunci API Tidak Ditemukan';
    String url = '$api?method=$method';

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
    String url =
        dotenv.env['CRUD_PLAYLIST_API_URL'] ?? 'Kunci API Tidak Ditemukan';

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

  Future<void> getDominantColorAlbum({required String albumCover}) async {
    final String api =
        dotenv.env['DOMINANT_COLOR_ALBUM_URL'] ?? 'Kunci API Tidak Ditemukan';
    try {
      final response = await http.post(Uri.parse(api), body: {
        'image_url': albumCover,
      });
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        defaultAlbumColor.value = body["dominant_color"]["bg_color"];
        logInfo('Dominant color album: $body');
      } else {
        logError("Error on getDominantColorAlbum: ${body['reason']}");
      }
    } catch (e, st) {
      logError("Error on getDominantColorAlbum: $e, stackTrace: $st");
    }
  }

  Future<void> getSimpleMode() async {
    final SharedPreferences prefs = await _prefs;
    final simpleMode = prefs.getBool('simple_mode') ?? false;
    isSimpleMode.value = simpleMode;
  }

  void toggleSimpleMode(bool value) async {
    final SharedPreferences prefs = await _prefs;
    isSimpleMode.value = value;

    if (value == true) {
      prefs.setBool('simple_mode', true);
    } else {
      prefs.setBool('simple_mode', false);
    }
  }
}
