import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_playlist_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_provider.dart';
import 'package:cybeat_music_player/screens/crud_playlist_screen/new_playlist_screen/new_playlist_screen.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/button_done.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/list_recently_added.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/list_saved_in.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/scale_tap.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class MusicPlaylistScreen extends StatelessWidget {
  const MusicPlaylistScreen({
    super.key,
    required this.idMusic,
    required this.audioState,
  });

  final String idMusic;
  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final musicPlaylistController = Get.put(MusicPlaylistController());
    final homeAlbumGridController = Get.find<HomeAlbumGridController>();
    // Ambil data playlist yang sudah ada.
    musicPlaylistController.getMusicOnPlaylist(idMusic: idMusic);
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: HexColor('#fefffe'),
          appBar: AppBar(
            backgroundColor: HexColor('#fefffe'),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 0,
            actions: const [SizedBox(width: 20)],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (musicPlaylistController.searchBarTapped.value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    musicPlaylistController.tapSearchBar(false);
                  });
                  musicPlaylistController.textController.clear();
                  musicPlaylistController.isTyping.value = false;
                } else {
                  Get.back();
                }
              },
            ),
            centerTitle: true,
            title: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: musicPlaylistController.searchBarTapped.value
                    ? searchBar(musicPlaylistController, needHint: false)
                    : const Text(
                        'Add to playlist',
                      ),
              ),
            ),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: double.infinity,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: musicPlaylistController.searchBarTapped.value
                                ? const SizedBox()
                                : Center(
                                    child: ScaleTap(
                                      onTap: () {
                                        Get.to(
                                          () => const NewPlaylistScreen(),
                                          transition: Transition.downToUp,
                                          fullscreenDialog: true,
                                          popGesture: false,
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            bottom: 40, top: 20),
                                        width: 150,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.8),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                            color: Colors.black
                                                .withValues(alpha: 0.8),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "New Playlist",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: musicPlaylistController.searchBarTapped.value
                                ? const SizedBox()
                                : GestureDetector(
                                    onTap: () {
                                      if (!musicPlaylistController
                                          .searchBarTapped.value) {
                                        musicPlaylistController
                                            .tapSearchBar(true);
                                      }
                                    },
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: searchBar(
                                        musicPlaylistController,
                                        needHint: true,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Obx(
                          () => AnimatedSlide(
                            duration: const Duration(milliseconds: 200),
                            offset:
                                musicPlaylistController.searchBarTapped.value
                                    ? const Offset(
                                        0,
                                        0,
                                      )
                                    : const Offset(0, 0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                if (musicPlaylistController.isTypingValue &&
                                        musicPlaylistController
                                            .textValue.value.isNotEmpty
                                    ? homeAlbumGridController
                                        .playlistCreatedList
                                        .where((element) {
                                          return musicPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      musicPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isNotEmpty
                                    : musicPlaylistController
                                        .listMusicOnPlaylist.isNotEmpty)
                                  Row(
                                    children: [
                                      const Text(
                                        'Saved in',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          musicPlaylistController.clearAll();
                                        },
                                        child: Text(
                                          'Clear all',
                                          style: TextStyle(
                                            color: HexColor('#8238be'),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                // List playlist yang disimpan.
                                ListSavedIn(
                                  homeAlbumGridController:
                                      homeAlbumGridController,
                                  musicPlaylistController:
                                      musicPlaylistController,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (musicPlaylistController.isTypingValue &&
                                        musicPlaylistController
                                            .textValue.value.isNotEmpty
                                    ? homeAlbumGridController
                                        .playlistCreatedList
                                        .where((element) {
                                          return !musicPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      musicPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isNotEmpty
                                    : homeAlbumGridController
                                        .playlistCreatedList
                                        .where(
                                          (element) => !musicPlaylistController
                                              .savedInMusicList
                                              .contains(element.uid),
                                        )
                                        .toList()
                                        .isNotEmpty) // Playlist yang belum disimpan.
                                  const ListTile(
                                    contentPadding: EdgeInsets
                                        .zero, // menghilangkan padding kiri kanan
                                    leading: Icon(
                                      Icons.list,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      'Recently added',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ListRecentlyAdded(
                                  homeAlbumGridController:
                                      homeAlbumGridController,
                                  musicPlaylistController:
                                      musicPlaylistController,
                                ),
                                if (musicPlaylistController.isTypingValue &&
                                    musicPlaylistController
                                        .textValue.value.isNotEmpty &&
                                    homeAlbumGridController.playlistCreatedList
                                        .where((element) {
                                          return !musicPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      musicPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isEmpty &&
                                    homeAlbumGridController.playlistCreatedList
                                        .where((element) {
                                          return musicPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      musicPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isEmpty)
                                  const Text(
                                    'No playlist found',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ButtonDone(
                    musicPlaylistController: musicPlaylistController,
                    idMusic: idMusic,
                    audioState: audioState,
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(
          () => musicPlaylistController.isLoadingGetMusicOnPlaylist.value ||
                  homeAlbumGridController.isLoadingAddPlaylist.value ||
                  homeAlbumGridController
                      .isLoading.value // Ini loading pas di home screen.
              ? const Opacity(
                  opacity: 1,
                  child: ModalBarrier(dismissible: false, color: Colors.white),
                )
              : const SizedBox(),
        ),
        Obx(
          () => musicPlaylistController.isLoadingGetMusicOnPlaylist.value ||
                  homeAlbumGridController.isLoadingAddPlaylist.value ||
                  homeAlbumGridController
                      .isLoading.value // Ini loading pas di home screen.
              ? Center(
                  child: CircularProgressIndicator(
                    color: HexColor('#8238be'),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
