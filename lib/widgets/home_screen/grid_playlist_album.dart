import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridViewPlaylistAlbum extends StatelessWidget {
  const GridViewPlaylistAlbum({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl:
                "https://i.scdn.co/image/ab67616d0000b273283da7197a2e5d610adfe4e9",
            fit: BoxFit.cover,
            maxHeightDiskCache: 200,
            maxWidthDiskCache: 200,
            filterQuality: FilterQuality.low,
            placeholder: (context, url) => Image.asset(
              'assets/images/placeholder_cover_music.png',
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/placeholder_cover_music.png',
              fit: BoxFit.cover,
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
                    text,
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
                const Text(
                  "Playlist ● Nasrul Wahabi",
                  style: TextStyle(
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
