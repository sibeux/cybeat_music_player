import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/controller/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:cybeat_music_player/screens/splash_screen/general_splash_screen.dart';
import 'package:cybeat_music_player/screens/splash_screen/splash_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class SplashLinkMusicScreen extends StatefulWidget {
  const SplashLinkMusicScreen({
    super.key,
    required this.path,
    required this.uid,
  });

  final String path;
  final String uid;

  @override
  State<SplashLinkMusicScreen> createState() => _SplashLinkMusicScreenState();
}

class _SplashLinkMusicScreenState extends State<SplashLinkMusicScreen> {
  List<Playlist> listPlaylist = [];
  late ConcatenatingAudioSource playlist;
  int _nextMediaId = 1;

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

    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    String url =
        "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?uid=${widget.uid}&type=${widget.path}";

    try {
      final response = await http.post(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));

      final List<dynamic> listData = json.decode(response.body);
      final List<dynamic> apiData = json.decode(apiResponse.body);

      if (listData.isEmpty) {
        await Future.delayed(const Duration(seconds: 2));
        FlutterNativeSplash.remove();
        Get.offAll(() => const SplashHomeScreen(
              path: '/',
            ));
        showToast('Playlist not found');
        return;
      }

      playlist = ConcatenatingAudioSource(
        children: listData.map(
          (item) {
            return AudioSource.uri(
              Uri.parse(regexGdriveLink(
                  item['link_gdrive'], apiData[0]['gdrive_api'])),
              tag: MediaItem(
                id: '${_nextMediaId++}',
                title: capitalizeEachWord(item['title']),
                artist: capitalizeEachWord(item['artist']),
                album: capitalizeEachWord(item['album']),
                artUri: Uri.parse(
                    regexGdriveLink(item['cover'], apiData[0]['gdrive_api'])),
                extras: {
                  'favorite': item['favorite'],
                  'music_id': item['id_music'],
                },
              ),
            );
          },
        ).toList(),
      );

      final list = Playlist(
        uid: listData[0]['uid'],
        title: capitalizeEachWord(listData[0]['name']),
        image: regexGdriveLink(listData[0]['image'],
            json.decode(apiResponse.body)[0]['gdrive_api']),
        type: capitalizeEachWord(listData[0]['type']),
        author: capitalizeEachWord(listData[0]['author']),
        pin: listData[0]['pin'],
        datePin: listData[0]['date_pin'] ?? '',
        date: listData[0]['date'],
        editable: listData[0]['editable'],
      );

      setState(() {
        listPlaylist = [list];
        developer.log('${listPlaylist[0].title} is loaded');
      });

      FlutterNativeSplash.remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();
    final playlistPlayController = Get.put(PlaylistPlayController());
    final playingStateController = Get.put(PlayingStateController());

    if (listPlaylist.isEmpty) {
      return const GeneralSplashScreen();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        playingStateController.pause();
        playlistPlayController.onPlaylist(listPlaylist[0]);
      });
      audioState.recreate();
      context.read<AudioState>().setSourceAudio(playlist);
      context.read<MusicState>().clear();
      return AzListMusicScreen(
        audioState: audioState,
      );
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
