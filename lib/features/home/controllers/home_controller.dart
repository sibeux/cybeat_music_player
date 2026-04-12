import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/filter_item.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeController extends GetxController {
  final AlbumService albumService = Get.find<AlbumService>();
  final AuthService authService = Get.find<AuthService>();
  final MusicPlayerController musicPlayerController = Get.find();

  var filterIsTapped = false.obs;
  var jumlahAlbumDitampilkan = 15.obs;
  var isTapped = false.obs;

  RxList<Album?> get selectedAlbum => albumService.selectedAlbum;
  RxList<Album> get initiateAlbum => albumService.initiateAlbum;
  RxList<int> get filterChildren => albumService.filterChildren;
  RxList<FilterItem> get generateFilter => albumService.generateFilter;
  RxString get selectedFilter => albumService.homeSelectedFilter;
  RxInt get albumCountGrid => albumService.albumCountGrid;
  RxList get allAlbumChildren => albumService.allAlbumChildren;
  dynamic get getSelectedFilter => albumService.getSelectedFilter;
  RxList get fourCoverPlaylist => albumService.fourCoverPlaylist;
  RxList get fourCoverCategory => albumService.fourCoverCategory;
  dynamic get sortValue => albumService.sortValue;
  RxList<Album> get playlistCreatedList => albumService.playlistCreatedList;
  bool get isLoading => albumService.isHomeLoading.value;
  RxString get fullName => authService.fullName;
  bool get isAuthenticated => authService.isAuthenticated;

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

  void onLoading(RefreshController refreshController) async {
    // monitor network fetch
    jumlahAlbumDitampilkan.value = jumlahAlbumDitampilkan.value + 18;
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    refreshController.loadComplete();
  }

  void onRefresh(RefreshController refreshController) async {
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

  void updateChildren(List<Album> playlist) {
    albumService.updateAllAlbumChildren(playlist);
    isTapped.value = !isTapped.value;
  }

  void changeLayoutGrid() {
    albumService.changeLayoutGrid();
  }

  void setCurrentMediaItem(MediaItem mediaItem) {
    musicPlayerController.updateCurrentMediaItem(mediaItem);
  }

  void getDominantColorAlbum({required Album album}) {
    String albumCover = '';
    if (album.image['default_cover'] != null) {
      albumCover = album.image['default_cover'].toString();
    } else {
      albumCover = album.image['cover_1'].toString();
    }
    if (albumCover != '') {
      albumService.getDominantColorAlbum(
          albumCover: albumCover, albumId: album.uid);
    }
  }

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
