import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeController extends GetxController {
  final AlbumService albumService = Get.find<AlbumService>();
  final MusicPlayerController musicPlayerController = Get.find();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  var filterIsTapped = false.obs;
  var jumlahAlbumDitampilkan = 15.obs;
  var isTapped = false.obs;

  get selectedAlbum => albumService.selectedAlbum;
  get initiateAlbum => albumService.initiateAlbum;
  get filterChildren => albumService.filterChildren;
  get generateFilter => albumService.generateFilter;
  get selectedFilter => albumService.homeSelectedFilter;
  get albumCountGrid => albumService.albumCountGrid;
  get allAlbumChildren => albumService.allAlbumChildren;
  get getSelectedFilter => albumService.getSelectedFilter;
  get fourCoverPlaylist => albumService.fourCoverPlaylist;
  get fourCoverCategory => albumService.fourCoverCategory;
  get sortValue => albumService.sortValue;
  get playlistCreatedList => albumService.playlistCreatedList;
  get isLoading => albumService.isHomeLoading.value;

  get currentMediaItem => musicPlayerController.getCurrentMediaItem;

  @override
  void onInit() async {
    // Ambil data filter sort dari Shared Preferences
    await albumService.getSortBy();
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
}
