import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/home_screen/filter/grid_filter.dart';
import 'package:cybeat_music_player/screens/search_album_screen/search_album_screen.dart';
import 'package:cybeat_music_player/widgets/floating_playing_music.dart';
import 'package:cybeat_music_player/screens/home_screen/list_album/scale_tap_playlist.dart';
import 'package:cybeat_music_player/screens/home_screen/sort/scale_tap_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key, required this.playlistList, required this.audioState});

  final List<Playlist> playlistList;
  final AudioState audioState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gridViewKey = GlobalKey();
  final _homeAlbumGridController = Get.put(HomeAlbumGridController());
  final _scrollController = ScrollController();

  @override
  void initState() {
    _updateChildrenFromPlaylist();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    if (widget.playlistList != oldWidget.playlistList) {
      _updateChildrenFromPlaylist();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateChildrenFromPlaylist() {
    // tidak perlu update children karena sudah diupdate di initiaeAlbum
    // _homeAlbumGridController.updateChildren(widget.playlistList);
  }

  @override
  Widget build(BuildContext context) {
    final PlayingStateController playingStateController =
        Get.put(PlayingStateController());
    final FilterAlbumController filterAlbumController =
        Get.put(FilterAlbumController());

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
                        image: NetworkImage(
                            'https://sibeux.my.id/images/sibe.png'),
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
                    const Expanded(
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                            () => SearchAlbumScreen(
                                  audioState: widget.audioState,
                                ),
                            transition: Transition.cupertino);
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
                    const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  () => filterAlbumController.isTapped.value
                      ? const GridFilter()
                      : const GridFilter(),
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
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
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
                thumbColor: HexColor('#ac8bc9').withOpacity(0.5),
                trackVisibility: false,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            const Row(
                              children: [
                                ScaleTapSort(),
                                Expanded(child: SizedBox()),
                                Icon(Icons.list_rounded),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Obx(
                              () => _homeAlbumGridController.isTapped.value
                                  ? _homeAlbumGridController.isLoading.value
                                      ? const SizedBox(
                                          height: 400,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : _homeAlbumGridController
                                              .initiateAlbum.isEmpty
                                          ? const Center(
                                              child: Text('No album found'),
                                            )
                                          : _getReorderableAlbum()
                                  : _homeAlbumGridController.isLoading.value
                                      ? const SizedBox(
                                          height: 400,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : _homeAlbumGridController
                                              .initiateAlbum.isEmpty
                                          ? const Center(
                                              child: Text('No album found'),
                                            )
                                          : _getReorderableAlbum(),
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
          Obx(
            () => playingStateController.isPlaying.value
                ? StreamBuilder<SequenceState?>(
                    stream: widget.audioState.player.sequenceStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final currentItem = snapshot.data?.currentSource;
                        context
                            .read<MusicState>()
                            .setCurrentMediaItem(currentItem!.tag as MediaItem);

                        return FloatingPlayingMusic(
                          audioState: widget.audioState,
                          currentItem: currentItem,
                        );
                      }
                      return const SizedBox();
                    },
                  )
                : const SizedBox(),
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
        return GridView(
          key: _gridViewKey,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          primary: false,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 15,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            childAspectRatio: 2 / 3.5,
          ),
          children: context,
        );
      },
    );
  }

  List<Widget> _getGeneratedChildren() {
    return List<Widget>.generate(
      widget.playlistList.length,
      (index) => _getChild(index: index),
    );
  }

  Widget _getChild({required int index}) {
    final children = _homeAlbumGridController.children;
    return CustomDraggable(
      key: Key(children[index].toString()),
      data: index,
      child: ScaleTapPlaylist(
        playlist: widget.playlistList[(children[index])],
        audioState: widget.audioState,
      ),
    );
  }
}
