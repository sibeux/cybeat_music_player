import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
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
    final playlistPlayController = Get.put(PlaylistPlayController());
    final playingStateController = Get.put(PlayingStateController());

    return GestureDetector(
      onTap: () {
        if (playlistPlayController.playlistTitleValue != playlist.title ||
            playlistPlayController.playlistTitleValue == "") {
          audioState.clear();
          playingStateController.pause();
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
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: playlist.image,
              fit: BoxFit.cover,
              height: 107,
              width: double.infinity,
              maxHeightDiskCache: 200,
              maxWidthDiskCache: 200,
              filterQuality: FilterQuality.low,
              placeholder: (context, url) => Image.asset(
                'assets/images/placeholder_cover_music.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/placeholder_cover_music.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
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
