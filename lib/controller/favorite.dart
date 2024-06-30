import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void setfavorite(String? id, String? isFavorite) async {
  String url =
      'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/favorite?_id=$id&_favorite=$isFavorite';

  try {
    await http.post(
      Uri.parse(url),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error set favorite: $e');
    }
  }
}
