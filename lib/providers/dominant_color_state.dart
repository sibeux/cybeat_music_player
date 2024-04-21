import 'package:cybeat_music_player/components/dominant_color.dart';
import 'package:flutter/material.dart';

class DominantColorState extends ChangeNotifier {
  Color _dominantColor = Colors.transparent;

  Color get dominantColor => _dominantColor;

  void setDominantColor(String artUri) {
    getDominantColor(artUri).then((color) {
      setColor(color!);
    _dominantColor = color;
    });
    notifyListeners();
  }

  void setColor(Color color) {
    _dominantColor = color;
  }
}
