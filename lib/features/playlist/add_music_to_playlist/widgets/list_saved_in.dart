
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/list_playlist_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListSavedIn extends StatelessWidget {
  const ListSavedIn({
    super.key,
    required this.addMusicToPlaylistController,
  });

  final AddMusicToPlaylistController addMusicToPlaylistController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true, // Agar ListView tidak error
        physics: const NeverScrollableScrollPhysics(),
        itemCount: addMusicToPlaylistController.isTypingValue &&
                addMusicToPlaylistController.textValue.value.isNotEmpty
            ? addMusicToPlaylistController.playlistCreatedList
                .where((element) {
                  return addMusicToPlaylistController.savedInMusicList
                          .contains(element.uid) &&
                      element.title.toLowerCase().contains(
                            addMusicToPlaylistController.textValue.value
                                .toLowerCase(),
                          );
                })
                .toList()
                .length
            : addMusicToPlaylistController.playlistCreatedList
                .where(
                  (element) => addMusicToPlaylistController.savedInMusicList
                      .contains(element.uid),
                )
                .toList()
                .length, // Playlist yang sudah disimpan.
        itemBuilder: (context, index) {
          return ListPlaylistContainer(
            index: index,
            listPlaylist: addMusicToPlaylistController.isTypingValue &&
                    addMusicToPlaylistController.textValue.value.isNotEmpty
                ? addMusicToPlaylistController.playlistCreatedList.where((element) {
                    return addMusicToPlaylistController.savedInMusicList
                            .contains(element.uid) &&
                        element.title.toLowerCase().contains(
                              addMusicToPlaylistController.textValue.value
                                  .toLowerCase(),
                            );
                  }).toList()
                : addMusicToPlaylistController.playlistCreatedList
                    .where(
                      (element) => addMusicToPlaylistController.savedInMusicList
                          .contains(element.uid),
                    )
                    .toList(), // Playlist yang sudah disimpan.
          );
        },
      ),
    );
  }
}
