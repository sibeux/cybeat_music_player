import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';

class FloatingPlayingMusicController extends GetxController {
  var listColor = RxList<Color>([Colors.black, Colors.white]);

  Future<void> getDominantColor(String url) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
          // Penyesuaian ukuran gambar agar lebih cepat.
      CachedNetworkImageProvider(
        url,
        maxHeight: 8,
        maxWidth: 8,
        scale: 0.1,
      ),
      size: const Size(256.0, 170.0),
      region: const Rect.fromLTRB(41.8, 4.4, 217.8, 170.0),
      maximumColorCount: 20,
    );

    final Map<String, Color?> color = {
      'lightMutedColor': paletteGenerator.lightMutedColor?.color,
      'darkMutedColor': paletteGenerator.darkMutedColor?.color,
      'lightVibrantColor': paletteGenerator.lightVibrantColor?.color,
      'darkVibrantColor': paletteGenerator.darkVibrantColor?.color,
      'mutedColor': paletteGenerator.mutedColor?.color,
      'vibrantColor': paletteGenerator.vibrantColor?.color,
    };

    double numLuminance = 0;
    Color fixColor = Colors.black;

    for (final value in color.values) {
      if (value != null &&
          value.computeLuminance() +
                  paletteGenerator.dominantColor!.color.computeLuminance() >
              numLuminance) {
        numLuminance = value.computeLuminance();
        fixColor = value;
      }
    }

    if (fixColor == paletteGenerator.dominantColor!.color) {
      fixColor = Colors.white;
    }
    final list = [paletteGenerator.dominantColor!.color, fixColor];
    listColor.value = list;
  }

  double isDark(Color background) {
    return (background.computeLuminance());
  }
}
