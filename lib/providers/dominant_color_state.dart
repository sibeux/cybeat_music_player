import 'package:cybeat_music_player/components/dominant_color.dart';
import 'package:flutter/material.dart';

class DominantColorState extends ChangeNotifier {
  Color _dominantColor = Colors.white;

  Color get dominantColor => _dominantColor;

  void setDominantColor(String artUri) {
    getDominantColor(artUri).then((color) {
      _dominantColor = color!;
    });
  }
}
