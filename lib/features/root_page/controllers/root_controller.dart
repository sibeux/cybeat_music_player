import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootController extends GetxController {
  final authService = Get.find<AuthService>();

  void clickLogin(BuildContext context) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200));
    Get.toNamed("/login");
  }

  void logout(BuildContext context) {
    final albumService = Get.find<AlbumService>();
    authService.logout();
    Navigator.of(context).pop();
    albumService.initializeAlbum();
  }
}
