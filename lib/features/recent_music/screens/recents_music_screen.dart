import 'dart:convert';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:cybeat_music_player/features/recent_music/widgets/recents_music_list.dart';
import 'package:cybeat_music_player/common/widgets/shimmer_music_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

var isPlaying = false;

class RecentsMusicScreen extends StatefulWidget {
  const RecentsMusicScreen({super.key});

  @override
  State<RecentsMusicScreen> createState() => _RecentsMusicScreenState();
}

class _RecentsMusicScreenState extends State<RecentsMusicScreen> {
  String? _error;
  var isLoading = true;
  List<Music> _musicItems = [];

  @override
  void initState() {
    super.initState();
    getMusicData();
  }

  void getMusicData() async {
    String userId = Get.find<AuthService>().userId.value.toString();
    String api = dotenv.env['PLAYLIST_API_URL'] ?? '';
    String url = '$api?recents_music=$userId';

    try {
      final response = await http.get(Uri.parse(url));

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
            musicId: int.tryParse(item['id_music']) ?? 0,
            title: item['title'],
            artist: item['artist'],
            album: item['album'] ?? "Unknown Album",
            cover: regexGdriveHostUrl(
              url: item['cover'],
              musicId: "0",
              isAudio: false,
            ),
            linkDrive: '',
            extras: {
              'key1': 'value1',
              'key2': 'value2',
            },
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
      logError(_error!);
      content = Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text("Error occured. Try Again later."),
        ),
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
            Get.back(id: 1);
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
        ],
      ),
    );
  }
}
