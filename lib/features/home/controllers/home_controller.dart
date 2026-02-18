import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/filter_item.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeController extends GetxController {
  final AlbumService albumService = Get.find<AlbumService>();
  final AuthService authService = Get.find<AuthService>();
  final MusicPlayerController musicPlayerController = Get.find();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  var filterIsTapped = false.obs;
  var jumlahAlbumDitampilkan = 15.obs;
  var isTapped = false.obs;

  RxList<Playlist?> get selectedAlbum => albumService.selectedAlbum;
  RxList<Playlist> get initiateAlbum => albumService.initiateAlbum;
  RxList<int> get filterChildren => albumService.filterChildren;
  RxList<FilterItem> get generateFilter => albumService.generateFilter;
  RxString get selectedFilter => albumService.homeSelectedFilter;
  RxInt get albumCountGrid => albumService.albumCountGrid;
  RxList get allAlbumChildren => albumService.allAlbumChildren;
  dynamic get getSelectedFilter => albumService.getSelectedFilter;
  RxList get fourCoverPlaylist => albumService.fourCoverPlaylist;
  RxList get fourCoverCategory => albumService.fourCoverCategory;
  dynamic get sortValue => albumService.sortValue;
  RxList<Playlist> get playlistCreatedList => albumService.playlistCreatedList;
  bool get isLoading => albumService.isHomeLoading.value;
  RxString get fullName => authService.fullName;

  MediaItem? get currentMediaItem => musicPlayerController.getCurrentMediaItem;

  @override
  void onInit() async {
    // Ambil data filter sort dari Shared Preferences
    await albumService.getSortBy();
    // Dapatkan mode music listview.
    await albumService.getSimpleMode();
    // Ambil data album dari database
    initializeAlbum();
    super.onInit();
  }

  void initializeAlbum() async {
    jumlahAlbumDitampilkan.value = 15;
    await albumService.initializeAlbum();
  }

  void onLoading() async {
    // monitor network fetch
    jumlahAlbumDitampilkan.value = jumlahAlbumDitampilkan.value + 18;
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    refreshController.loadComplete();
  }

  void onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));
    initializeAlbum();
    // if failed,use refreshFailed()
    refreshController.refreshCompleted();
  }

  void pinAlbum(String uid) {
    albumService.pinAlbum(uid);
    isTapped.value = !isTapped.value;
  }

  void unpinAlbum(String uid) {
    albumService.unpinAlbum(uid);
    isTapped.value = !isTapped.value;
  }

  void removePlaylist(String uid) {
    albumService.removePlaylist(uid);
    isTapped.value = !isTapped.value;
  }

  void onTapFilter({required String filter}) {
    albumService.onTapFilter(filter: filter);
    filterIsTapped.value = !filterIsTapped.value;
    initializeAlbum();
  }

  void onResetFilter() {
    albumService.onResetFilter();
    filterIsTapped.value = !filterIsTapped.value;
    initializeAlbum();
  }

  void updateLastPlayedAlbum(String uid) async {
    final needRebuild = await albumService.updateLastPlayedAlbum(uid);
    if (needRebuild) {
      isTapped.value = !isTapped.value;
    }
  }

  Future<void> saveSortBy(String title) async {
    await albumService.saveSortBy(title);
    initializeAlbum();
  }

  void updateChildren(List<Playlist> playlist) {
    albumService.updateAllAlbumChildren(playlist);
    isTapped.value = !isTapped.value;
  }

  void changeLayoutGrid() {
    albumService.changeLayoutGrid();
  }

  void setCurrentMediaItem(MediaItem mediaItem) {
    musicPlayerController.updateCurrentMediaItem(mediaItem);
  }

  void getDominantColorAlbum({required Playlist playlist}) {
    albumService.defaultAlbumColor.value = 'ffffff';
    String albumCover = '';
    if (playlist.image == "") {
      // Ini sebenarnya bisa diambilkan dari home screen, tapi perlu oper-oper data.
      final List<dynamic> list = playlist.type.toLowerCase() == 'playlist'
          ? fourCoverPlaylist
          : fourCoverCategory;

      final data = list
          .where((element) => element['playlist_uid'] == playlist.uid)
          .map((e) => {
                'cover_1': e['cover_1'],
                'cover_2': e['cover_2'],
                'cover_3': e['cover_3'],
                'cover_4': e['cover_4'],
                'total_non_null_cover': e['total_non_null_cover']
              })
          .toList();
      albumCover = data[0]['cover_1'] ?? '';
    } else {
      albumCover = playlist.image;
    }
    if (albumCover != '') {
      albumService.getDominantColorAlbum(albumCover: albumCover);
    }
  }

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
