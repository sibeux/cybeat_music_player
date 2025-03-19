import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/controller/music_play/read_codec_controller.dart';
import 'package:cybeat_music_player/controller/sort_preferences_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SplashHomeScreen extends StatefulWidget {
  const SplashHomeScreen({super.key, required this.path});

  final String path;

  @override
  State<SplashHomeScreen> createState() => _SplashHomeScreenState();
}

class _SplashHomeScreenState extends State<SplashHomeScreen> {
  final homeAlbumGridController = Get.put(HomeAlbumGridController());
  final sortPreferencesController = Get.put(SortPreferencesController());

  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> initialization() async {
    // Harus dipanggil sebelum splash hilang karena di home screen dipakai.
    Get.put(MusicStateController());

    // Menghilangkan splash screen
    FlutterNativeSplash.remove();
    // Ambil data filter sort dari Shared Preferences
    await sortPreferencesController.getSortBy();
    // Ambil data album dari database
    await homeAlbumGridController.initializeAlbum();
    
    // Inisiasi controller
    Get.put(PlaylistPlayController());
    Get.put(MusicDownloadController());
    Get.put(ReadCodecController());

    // print('ready in 3...');
    // await Future.delayed(const Duration(seconds: 1));
    // print('ready in 2...');
    // await Future.delayed(const Duration(seconds: 1));
    // print('ready in 1...');
    // await Future.delayed(const Duration(seconds: 1));
    // print('go!');
    // FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final audioState = context.watch<AudioState>();

    switch (widget.path) {
      case '/':
        return HomeScreen(audioState: audioState);
      default:
        return HomeScreen(audioState: audioState);
    }
  }
}
