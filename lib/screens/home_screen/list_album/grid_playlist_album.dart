import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
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

class CoverFullGrid extends StatelessWidget {
  const CoverFullGrid({
    super.key,
    required this.image,
    required this.size,
  });

  final String image;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      height: size,
      width: size,
      maxHeightDiskCache: 200,
      maxWidthDiskCache: 200,
      filterQuality: FilterQuality.low,
      placeholder: (context, url) => Image.asset(
        'assets/images/placeholder_cover_music.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/cybeat_splash.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}

class FourCoverAlbum extends StatelessWidget {
  const FourCoverAlbum({
    super.key,
    required this.size,
    required this.type,
    required this.playlist,
  });

  final double size;
  final String type;
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final homeAlbumGridController = Get.put(HomeAlbumGridController());

    List listCover(String uid, String type) {
      final List<dynamic> list = type == 'playlist'
          ? homeAlbumGridController.fourCoverPlaylist
          : homeAlbumGridController.fourCoverCategory;

      return list
          .where((element) => element['playlist_uid'] == uid)
          .map((e) => {
                'cover_1': e['cover_1'],
                'cover_2': e['cover_2'],
                'cover_3': e['cover_3'],
                'cover_4': e['cover_4'],
                'total_non_null_cover': e['total_non_null_cover']
              })
          .toList();
    }

    if (playlist.image != "") {
      return CoverFullGrid(size: size, image: playlist.image);
    } else {
      if (listCover(playlist.uid, playlist.type)[0]['total_non_null_cover'] !=
          '4') {
        if (listCover(playlist.uid, playlist.type)[0]['cover_1'] == null) {
          return CoverFullGrid(size: size, image: '');
        } else {
          final index =
              listCover(playlist.uid, playlist.type)[0]['total_non_null_cover'];
          return CoverFullGrid(
            size: size,
            image: listCover(playlist.uid, playlist.type)[0]['cover_$index'],
          );
        }
      } else {
        return SizedBox(
          height: size,
          width: size,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1, // Atur rasio item grid sesuai
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: 4,
                  (context, index) => CachedNetworkImage(
                    imageUrl: listCover(playlist.uid, playlist.type)[0]
                        ['cover_${index + 1}'],
                    fit: BoxFit.cover,
                    maxHeightDiskCache: 150,
                    maxWidthDiskCache: 150,
                    filterQuality: FilterQuality.low,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/placeholder_cover_music.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/cybeat_splash.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
