import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/widgets/home_widget/filter/grid_filter.dart';
import 'package:cybeat_music_player/screens/crud_playlist_screen/new_playlist_screen/show_new_playlist_modal.dart';
import 'package:cybeat_music_player/screens/recents_screen/recents_screen.dart';
import 'package:cybeat_music_player/screens/search_album_screen/search_album_screen.dart';
import 'package:cybeat_music_player/widgets/home_widget/list_album/scale_tap_playlist.dart';
import 'package:cybeat_music_player/widgets/home_widget/sort/scale_tap_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.audioState});

  final AudioState audioState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gridViewKey = GlobalKey();
  final _homeAlbumGridController = Get.find<HomeAlbumGridController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filterAlbumController = Get.find<FilterAlbumController>();
    final playingStateController = Get.find<PlayingStateController>();
    final musicStateController = Get.find<MusicStateController>();

    /*
    Setiap lagu berganti, maka akan memanggil fungsi setCurrentMediaItem-
    untuk mengubah data lagu yang sedang diputar. Agar nomor dan nama lagu- 
    yang sedang diputar berubah jadi ungu.
    */
    ever(
      musicStateController.currentMusicPlay,
      (callback) => context
          .read<MusicState>()
          .setCurrentMediaItem(musicStateController.currentMusicPlay[0]),
    );

    return Scaffold(
      backgroundColor: HexColor('#fefffe'),
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 30,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(
                        image: AssetImage('assets/images/cybeat_splash.png'),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text(
                        'Your Library',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final musicDownloadController =
                            Get.find<MusicDownloadController>();
                        musicDownloadController.goOfflineScreen(
                          audioState: widget.audioState,
                          playingStateController: playingStateController,
                          context: context,
                        );
                      },
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => RecentsScreen(audioState: widget.audioState),
                          transition: Transition.native,
                          popGesture: false,
                          fullscreenDialog: true,
                          id: 1,
                        );
                      },
                      child: const Icon(
                        Icons.history,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => SearchAlbumScreen(
                            audioState: widget.audioState,
                          ),
                          transition: Transition.cupertino,
                          popGesture: false,
                          fullscreenDialog: true,
                          id: 1,
                        );
                      },
                      child: const Icon(
                        Icons.search_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showNewPlaylistModal(context);
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 30,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  // Awalnya, GridFilter ada const, tetapi di release mode,
                  // dia tidak bergeser, sehingga const dihapus.
                  () => filterAlbumController.isTapped.value ||
                          !filterAlbumController.isTapped.value
                      ? GridFilter()
                      : SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Divider(
              color: Colors.grey.withValues(alpha: 0.3),
              thickness: 2,
              height: 0,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: RawScrollbar(
                radius: const Radius.circular(10),
                controller: _scrollController,
                thumbVisibility: false,
                timeToFade: const Duration(milliseconds: 500),
                padding: const EdgeInsets.only(top: 55),
                thickness: 5,
                thumbColor: HexColor('#ac8bc9').withValues(alpha: 0.7),
                trackVisibility: false,
                child: SmartRefresher(
                  controller: _homeAlbumGridController.refreshController,
                  scrollController: _scrollController,
                  onRefresh: _homeAlbumGridController.onRefresh,
                  onLoading: _homeAlbumGridController.onLoading,
                  enablePullDown: true,
                  enablePullUp: true,
                  header: const ClassicHeader(
                    height: 40,
                    refreshStyle: RefreshStyle.Follow,
                    refreshingIcon: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    ),
                    releaseText: 'Release to refresh',
                    refreshingText: 'Loading data...',
                    completeText: 'Success',
                    idleText: 'Pull down to refresh',
                    failedText: 'Failed',
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  footer: const ClassicFooter(
                    height: 40,
                    loadStyle: LoadStyle.ShowWhenLoading,
                    loadingIcon: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    ),
                    idleText: 'Pull up to load more',
                    loadingText: 'Loading data...',
                    noDataText: 'No more data',
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  ScaleTapSort(),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      _homeAlbumGridController
                                          .changeLayoutGrid();
                                    },
                                    child: Obx(
                                      () => _homeAlbumGridController
                                                  .countGrid.value ==
                                              1
                                          ? Icon(Icons.view_list_outlined)
                                          : Icon(Icons.grid_view_outlined),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Obx(
                                () => _homeAlbumGridController.isTapped.value ||
                                        !_homeAlbumGridController.isTapped.value
                                    ? _homeAlbumGridController.isLoading.value
                                        ? const SizedBox(
                                            height: 400,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : _homeAlbumGridController
                                                .initiateAlbum.isEmpty
                                            ? const Center(
                                                child: Text('No album found'),
                                              )
                                            : _getReorderableAlbum()
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        // ini sama aja padding kanan 20
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // mengambil data dari playlistList
  Widget _getReorderableAlbum() {
    final generatedChildren = _getGeneratedChildren();

    return ReorderableBuilder(
      onReorder: (p0) {},
      children: generatedChildren,
      builder: (context) {
        return Obx(
          () => GridView(
            key: _gridViewKey,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 15,
              mainAxisSpacing: 10,
              crossAxisCount: _homeAlbumGridController.countGrid.value,
              childAspectRatio: _homeAlbumGridController.countGrid.value == 1
                  ? 40 / 9
                  : 2 / 3.5,
            ),
            children: context,
          ),
        );
      },
    );
  }

  List<Widget> _getGeneratedChildren() {
    return List<Widget>.generate(
      _homeAlbumGridController.selectedAlbum.length >= 15
          ? _homeAlbumGridController.jumlahDitampilkan.value
          : _homeAlbumGridController.selectedAlbum.length,
      (index) => _getChild(index: index),
    );
  }

  Widget _getChild({required int index}) {
    return CustomDraggable(
      key: Key(_homeAlbumGridController.children[index].toString()),
      data: index,
      child: ScaleTapPlaylist(
        playlist: _homeAlbumGridController
            .initiateAlbum[(_homeAlbumGridController.children[index])],
        audioState: widget.audioState,
      ),
    );
  }
}
