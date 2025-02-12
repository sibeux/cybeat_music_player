import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_playlist_controller.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/list_playlist_container.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class MusicPlaylistScreen extends StatelessWidget {
  const MusicPlaylistScreen({super.key, required this.idMusic});

  final String idMusic;

  @override
  Widget build(BuildContext context) {
    final musicPlaylistController = Get.put(MusicPlaylistController());
    final homeAlbumGridController = Get.find<HomeAlbumGridController>();
    return Scaffold(
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
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: musicPlaylistController.searchBarTapped.value
                            ? 0.0
                            : 1.0,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 40, top: 20),
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.8),
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
                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: musicPlaylistController.searchBarTapped.value
                            ? 0.0
                            : 1.0,
                        child: GestureDetector(
                          onTap: () {
                            if (!musicPlaylistController
                                .searchBarTapped.value) {
                              musicPlaylistController.tapSearchBar(true);
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
                        offset: musicPlaylistController.searchBarTapped.value
                            ? const Offset(
                                0,
                                -0.2,
                              )
                            : const Offset(0, 0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            if (musicPlaylistController
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
                                    onPressed: () {},
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
                            ListView.builder(
                              shrinkWrap: true, // Agar ListView tidak error
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: musicPlaylistController
                                  .listMusicOnPlaylist.length,
                              itemBuilder: (context, index) {
                                return ListPlaylistContainer(
                                  index: index,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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
                            ListView.builder(
                              shrinkWrap: true, // Agar ListView tidak error
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: homeAlbumGridController
                                  .playlistCreatedList.length,
                              itemBuilder: (context, index) {
                                return ListPlaylistContainer(
                                  index: index,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      musicPlaylistController.updateMusicOnPlaylist(
                        idMusic: idMusic,
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        color: HexColor('#8238be'),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: HexColor('#8238be'),
                          width: 1,
                        ),
                      ),
                      child: Obx(
                        () => Center(
                          child: musicPlaylistController
                                  .isLoadingUpdateMusicOnPlaylist.value
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Done",
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
            ],
          ),
        ),
      ),
    );
  }
}
