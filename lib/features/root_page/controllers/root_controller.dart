import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:cybeat_music_player/core/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootController extends GetxController {
  final authService = Get.find<AuthService>();

  void clickLogin(BuildContext context) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 100));
    Get.toNamed("/login");
  }

  Future<void> logout(BuildContext context) async {
    final storage = Get.find<SecureStorageService>();
    final refreshToken = await storage.getRefreshToken();

    try {
      await authService.logoutUser(refreshToken: refreshToken ?? '');
      logSuccess('Server logout success');
    } catch (e, st) {
      logWarning('Server logout failed/error: $e $st');
    }

    authService.logout();

    if (context.mounted) {
      // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      Navigator.of(context).pop();
    }

    final albumService = Get.find<AlbumService>();
    albumService.initializeAlbum();
  }
}
