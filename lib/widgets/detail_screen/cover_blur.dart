import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CoverBlur extends StatelessWidget {
  const CoverBlur({
    super.key,
    required this.player,
  });

  final AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SequenceState?>(
      stream: player?.sequenceStateStream,
      builder: (context, snapshot) {
        String cover = 'https://raw.githubusercontent.com/sibeux/license-sibeux/MyProgram/placeholder_cover_music.png';

        if (snapshot.hasData) {
          final currentItem = snapshot.data?.currentSource;
          cover = currentItem!.tag.artUri.toString();
        }

        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaY: 35,
            sigmaX: 35,
          ),
          child: CachedNetworkImage(
            imageUrl: cover,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            color: Colors.black.withOpacity(0.5),
            memCacheHeight: 20,
            memCacheWidth: 20,
            colorBlendMode: BlendMode.darken,
            progressIndicatorBuilder: (context, url, progress) => Container(
              color: Colors.black,
            ),
            errorWidget: (context, exception, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 126, 248, 60),
                      Color.fromARGB(255, 253, 123, 123),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
