import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:cybeat_music_player/screens/home_screen/list_album/four_cover_album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

class GridPlaylistAlbum extends StatelessWidget {
  const GridPlaylistAlbum({
    super.key,
    required this.playlist,
    required this.audioState,
  });

  final Playlist playlist;
  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final playlistPlayController = Get.find<PlaylistPlayController>();
    final playingStateController = Get.put(PlayingStateController());
    final musicStateController = Get.find<MusicStateController>();

    return GestureDetector(
      onTap: () {
        if (playlistPlayController.playlistTitleValue != playlist.title ||
            playlistPlayController.playlistTitleValue == "") {
          audioState.clear();
          playingStateController.pause();
          musicStateController.onClose();
          context.read<MusicState>().clear();
          audioState.init(playlist);
          playlistPlayController.onPlaylist(playlist);
        }

        Get.to(
          () => AzListMusicScreen(
            audioState: audioState,
          ),
          transition: Transition.leftToRightWithFade,
          duration: const Duration(milliseconds: 300),
          popGesture: false,
          fullscreenDialog: true,
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            FourCoverAlbum(
              size: 108,
              type: playlist.type,
              playlist: playlist,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Obx(() => AutoSizeText(
                          playlist.title,
                          textAlign: TextAlign.left,
                          maxFontSize: 14,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: HexColor(
                                playlistPlayController.playlistUidValue ==
                                        playlist.uid
                                    ? '#8238be'
                                    : '#313031'),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        )),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    children: [
                      if (playlist.pin == "true")
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: HexColor('#8238be'),
                        ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          "${playlist.type} ● ${playlist.author}",
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
