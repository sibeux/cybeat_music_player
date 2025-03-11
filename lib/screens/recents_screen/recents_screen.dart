import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/playing_state_controller.dart';
import 'package:cybeat_music_player/models/music.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/recents_screen/recents_music_list.dart';
import 'package:cybeat_music_player/widgets/shimmer_music_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './/./widgets/floating_playing_music.dart';

var isPlaying = false;

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key, required this.audioState});

  final AudioState audioState;

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

String filteredUrl(String url, String key) {
  if (url.contains('drive.google.com')) {
    RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    Match? match = regExp.firstMatch(url);
    return 'https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key';
  } else {
    return url;
  }
}

class _RecentsScreenState extends State<RecentsScreen> {
  String? _error;
  var isLoading = true;
  List<Music> _musicItems = [];

  @override
  void initState() {
    super.initState();
    getMusicData();
  }

  void getMusicData() async {
    const url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist?recents_music';
    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    try {
      final response = await http.get(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));

      final List<dynamic> apiData = json.decode(apiResponse.body);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to load items';
        });
      }

      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final List<dynamic> listData = json.decode(response.body);
      final List<Music> loadedItems = [];

      for (final item in listData) {
        loadedItems.add(
          Music(
            uid: item['id_music'],
            title: item['title'],
            artist: item['artist'],
            album: item['album'],
            cover: filteredUrl(item['cover'], apiData[0]['gdrive_api']),
            linkDrive: item['link_gdrive'],
            time: item['time'],
            favorite: item['favorite'],
            category: item['category'],
            dateAdded: item['date_added'],
          ),
        );
      }

      setState(() {
        _musicItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      setState(
        () {
          _error = e.toString();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget content = const Center(
      child: Text('No music in recents!'),
    );

    if (isLoading) {
      content = const ShimmerMusicList();
    }

    final playingStateController = Get.put(PlayingStateController());

    if (_musicItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _musicItems.length,
        physics: const ClampingScrollPhysics(),
        primary: false,
        itemBuilder: (context, index) {
          return RecentMusicList(
            index: index,
            music: _musicItems[index],
          );
        },
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          tooltip: 'Menu',
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        toolbarHeight: 60,
        title: Text(
          'Recents Music',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: HexColor('#1e0b2b'),
            fontSize: 21,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: HexColor('#fefffe'),
                          padding: const EdgeInsets.only(top: 8),
                          width: double.infinity,
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => playingStateController.isPlaying.value
                ? StreamBuilder<SequenceState?>(
                    stream: widget.audioState.player.sequenceStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final currentItem = snapshot.data?.currentSource;
                        context
                            .read<MusicState>()
                            .setCurrentMediaItem(currentItem!.tag as MediaItem);

                        return FloatingPlayingMusic(
                          audioState: widget.audioState,
                          currentItem: currentItem,
                        );
                      }
                      return const SizedBox();
                    },
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
