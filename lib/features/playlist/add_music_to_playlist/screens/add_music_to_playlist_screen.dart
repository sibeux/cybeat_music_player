import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/button_done.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/list_recently_added.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/list_saved_in.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/scale_tap.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AddMusicToPlaylistScreen extends StatelessWidget {
  const AddMusicToPlaylistScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final idMusic = Get.arguments['idMusic'] ?? '';
    final addMusicToPlaylistController =
        Get.find<AddMusicToPlaylistController>();
    // Ambil data playlist yang sudah ada.
    addMusicToPlaylistController.getMusicOnPlaylist(idMusic: idMusic);
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
                if (addMusicToPlaylistController.searchBarTapped.value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    addMusicToPlaylistController.tapSearchBar(false);
                  });
                  addMusicToPlaylistController.textController.clear();
                  addMusicToPlaylistController.isTyping.value = false;
                } else {
                  Get.back();
                }
              },
            ),
            centerTitle: true,
            title: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: addMusicToPlaylistController.searchBarTapped.value
                    ? searchBar(addMusicToPlaylistController, needHint: false)
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
                            child: addMusicToPlaylistController
                                    .searchBarTapped.value
                                ? const SizedBox()
                                : Center(
                                    child: ScaleTap(
                                      onTap: () {
                                        Get.toNamed('/new_playlist');
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
                            child: addMusicToPlaylistController
                                    .searchBarTapped.value
                                ? const SizedBox()
                                : GestureDetector(
                                    onTap: () {
                                      if (!addMusicToPlaylistController
                                          .searchBarTapped.value) {
                                        addMusicToPlaylistController
                                            .tapSearchBar(true);
                                      }
                                    },
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: searchBar(
                                        addMusicToPlaylistController,
                                        needHint: true,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Obx(
                          () => AnimatedSlide(
                            duration: const Duration(milliseconds: 200),
                            offset: addMusicToPlaylistController
                                    .searchBarTapped.value
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
                                if (addMusicToPlaylistController
                                            .isTypingValue &&
                                        addMusicToPlaylistController
                                            .textValue.value.isNotEmpty
                                    ? addMusicToPlaylistController
                                        .playlistCreatedList
                                        .where((element) {
                                          return addMusicToPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      addMusicToPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isNotEmpty
                                    : addMusicToPlaylistController
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
                                          addMusicToPlaylistController
                                              .clearAll();
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
                                  addMusicToPlaylistController:
                                      addMusicToPlaylistController,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (addMusicToPlaylistController
                                            .isTypingValue &&
                                        addMusicToPlaylistController
                                            .textValue.value.isNotEmpty
                                    ? addMusicToPlaylistController
                                        .playlistCreatedList
                                        .where((element) {
                                          return !addMusicToPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      addMusicToPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isNotEmpty
                                    : addMusicToPlaylistController
                                        .playlistCreatedList
                                        .where(
                                          (element) =>
                                              !addMusicToPlaylistController
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
                                  addMusicToPlaylistController:
                                      addMusicToPlaylistController,
                                ),
                                if (addMusicToPlaylistController
                                        .isTypingValue &&
                                    addMusicToPlaylistController
                                        .textValue.value.isNotEmpty &&
                                    addMusicToPlaylistController
                                        .playlistCreatedList
                                        .where((element) {
                                          return !addMusicToPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      addMusicToPlaylistController
                                                          .textValue.value
                                                          .toLowerCase());
                                        })
                                        .toList()
                                        .isEmpty &&
                                    addMusicToPlaylistController
                                        .playlistCreatedList
                                        .where((element) {
                                          return addMusicToPlaylistController
                                                  .savedInMusicList
                                                  .contains(element.uid) &&
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      addMusicToPlaylistController
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
                    musicPlaylistController: addMusicToPlaylistController,
                    idMusic: idMusic,
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(
          () => addMusicToPlaylistController
                      .isLoadingGetMusicOnPlaylist.value ||
                  addMusicToPlaylistController.isLoadingAddPlaylist.value ||
                  addMusicToPlaylistController
                      .isHomeLoading // Ini loading pas di home screen.
              ? const Opacity(
                  opacity: 1,
                  child: ModalBarrier(dismissible: false, color: Colors.white),
                )
              : const SizedBox(),
        ),
        Obx(
          () =>
              addMusicToPlaylistController.isLoadingGetMusicOnPlaylist.value ||
                      addMusicToPlaylistController.isLoadingAddPlaylist.value ||
                      addMusicToPlaylistController
                          .isHomeLoading // Ini loading pas di home screen.
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
