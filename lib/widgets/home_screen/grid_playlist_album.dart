import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:flutter/material.dart';

class GridViewPlaylistAlbum extends StatelessWidget {
  const GridViewPlaylistAlbum({
    super.key,
    required this.playlist,
  });

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AzListMusicScreen(
                      playlist: playlist,
                    )));
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
                      style: const TextStyle(
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
