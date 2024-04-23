import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<List<Color?>> getDominantColor(String url) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(NetworkImage(url));

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
  return [paletteGenerator.dominantColor!.color, fixColor];
}

double isDark(Color background) {
  return (background.computeLuminance());
}
