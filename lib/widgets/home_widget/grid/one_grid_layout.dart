import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/widgets/home_widget/list_album/four_cover_album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class OneGridLayout extends StatelessWidget {
  const OneGridLayout({
    super.key,
    required this.playlist,
    required this.playlistPlayController,
  });

  final Playlist playlist;
  final PlaylistPlayController playlistPlayController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FourCoverAlbum(
          size: 80,
          type: playlist.type,
          playlist: playlist,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Obx(() => AutoSizeText(
                      playlist.title,
                      textAlign: TextAlign.left,
                      maxFontSize: 15,
                      minFontSize: 15,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HexColor(
                            playlistPlayController.playlistUidValue ==
                                    playlist.uid
                                ? '#8238be'
                                : '#313031'),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    )),
              ),
              const SizedBox(
                height: 15,
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
    );
  }
}
