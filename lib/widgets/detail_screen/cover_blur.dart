import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/providers/audio_source_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoverBlur extends StatelessWidget {
  const CoverBlur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    
    final currentItem = context.watch<AudioSourceState>().audioSource;
    
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaY: 35,
        sigmaX: 35,
      ),
      child: CachedNetworkImage(
        imageUrl: currentItem!.tag.artUri.toString(),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        color: Colors.black.withOpacity(0.5),
        memCacheHeight: 20,
        memCacheWidth: 20,
        colorBlendMode: BlendMode.darken,
        progressIndicatorBuilder: (context, url, progress) =>
            Container(
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
  }
}
