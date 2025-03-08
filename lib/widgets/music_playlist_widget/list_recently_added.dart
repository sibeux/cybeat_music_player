import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_playlist_controller.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/list_playlist_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListRecentlyAdded extends StatelessWidget {
  const ListRecentlyAdded({
    super.key,
    required this.homeAlbumGridController,
    required this.musicPlaylistController,
  });

  final HomeAlbumGridController homeAlbumGridController;
  final MusicPlaylistController musicPlaylistController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true, // Agar ListView tidak error
        physics: const NeverScrollableScrollPhysics(),
        itemCount: musicPlaylistController.isTypingValue &&
                musicPlaylistController.textValue.value.isNotEmpty
            ? homeAlbumGridController.playlistCreatedList
                .where((element) {
                  return !musicPlaylistController.savedInMusicList
                          .contains(element.uid) &&
                      element.title.toLowerCase().contains(
                          musicPlaylistController.textValue.value
                              .toLowerCase());
                })
                .toList()
                .length // Playlist yang belum disimpan.
            : homeAlbumGridController.playlistCreatedList
                .where((element) => !musicPlaylistController.savedInMusicList
                    .contains(element.uid))
                .toList()
                .length, // Playlist yang belum disimpan.
        itemBuilder: (context, index) {
          return ListPlaylistContainer(
            index: index,
            listPlaylist: musicPlaylistController.isTypingValue &&
                    musicPlaylistController.textValue.value.isNotEmpty
                ? homeAlbumGridController.playlistCreatedList.where((element) {
                    return !musicPlaylistController.savedInMusicList
                            .contains(element.uid) &&
                        element.title.toLowerCase().contains(
                            musicPlaylistController.textValue.value
                                .trim()
                                .toLowerCase());
                  }).toList()
                : homeAlbumGridController.playlistCreatedList
                    .where(
                      (element) => !musicPlaylistController.savedInMusicList
                          .contains(element.uid),
                    )
                    .toList(), // Playlist yang belum disimpan.
          );
        },
      ),
    );
  }
}
