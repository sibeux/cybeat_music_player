import 'dart:convert';

import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/controller/sort_preferences_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SplashHomeScreen extends StatefulWidget {
  const SplashHomeScreen({super.key, required this.path});

  final String path;

  @override
  State<SplashHomeScreen> createState() => _SplashHomeScreenState();
}

class _SplashHomeScreenState extends State<SplashHomeScreen> {
  List<Playlist> listPlaylist = [];
  final sortPreferencesController = Get.put(SortPreferencesController());

  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print

    await sortPreferencesController.getSortBy();
    final sort = sortPreferencesController.sort.value;

    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?sort=$sort';

    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    try {
      final response = await http.post(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));

      final List<dynamic> listData = json.decode(response.body);
      final List<dynamic> apiData = json.decode(apiResponse.body);

      final list = listData.map((item) {
        return Playlist(
          uid: item['uid'],
          title: capitalizeEachWord(item['name']),
          image: regexGdriveLink(item['image'], apiData[0]['gdrive_api']),
          type: capitalizeEachWord(item['type']),
          pin: item['pin'],
          date: item['date'],
        );
      }).toList();

      setState(() {
        listPlaylist = list;
      });

      FlutterNativeSplash.remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

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
        return HomeScreen(playlistList: listPlaylist, audioState: audioState);
      default:
        return HomeScreen(playlistList: listPlaylist, audioState: audioState);
    }
  }

  String regexGdriveLink(String url, String key) {
    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      return 'https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key';
    } else if (url.contains('www.googleapis.com')) {
      final regExp = RegExp(r'files\/([a-zA-Z0-9_-]+)\?');
      final match = regExp.firstMatch(url);
      return "https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key";
    } else {
      return url;
    }
  }
}
