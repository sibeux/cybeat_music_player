import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/providers/playing_state.dart';
import 'package:cybeat_music_player/providers/playlist_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class GridViewPlaylistAlbum extends StatelessWidget {
  const GridViewPlaylistAlbum({
    super.key,
    required this.playlist,
    required this.audioState,
  });

  final Playlist playlist;
  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final playlistDimainkan = context.watch<PlaylistState>().currentPlaylist;
    String colorTitle = "#313031";

    if (playlistDimainkan?.uid == playlist.uid) {
      colorTitle = '#8238be';
    }

    return GestureDetector(
      onTap: () {
        if (context.read<PlaylistState>().currentPlaylist?.uid == "" ||
            context.read<PlaylistState>().currentPlaylist?.uid !=
                playlist.uid) {
          context.read<PlaylistState>().setCurrentPlaylist(playlist);
          audioState.clear();
          context.read<PlayingState>().pause();
          context.read<MusicState>().clear();
          audioState.init(playlist);
          audioState.player.play();
        }
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 300),
            child: AzListMusicScreen(
              playlist: playlist,
              audioState: audioState,
            ),
            childCurrent: context.widget,
          ),
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
                    child: AutoSizeText(
                      playlist.title,
                      textAlign: TextAlign.left,
                      maxFontSize: 14,
                      minFontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HexColor(colorTitle),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Text(
                    "${playlist.type} ● Nasrul Wahabi",
                    style: const TextStyle(
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
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
