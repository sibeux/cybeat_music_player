
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<Color?> getDominantColor(String url) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(NetworkImage(url));

  return paletteGenerator.dominantColor?.color;
}
