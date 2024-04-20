import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/widgets/music_list.dart';
import 'package:cybeat_music_player/widgets/shimmer_music_list.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String? _error;
  var isLoading = true;
  bool isLoadingVertical = false;
  final int increment = 10;
  Color dominantColor = Colors.transparent;

  StreamSubscription? _playerCompleteSubscription;

  void setColor(Color color) {
    setState(() {
      dominantColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMoreVertical();
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  Future _loadMoreVertical() async {
    setState(() {
      isLoadingVertical = true;
    });

    // Add in an artificial delay
    await Future.delayed(
      const Duration(seconds: 2),
    );

    setState(() {
      isLoadingVertical = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    Widget content = const Center(
      child: Text('No music yet! Add some!'),
    );

    // if (isLoading) {
    //   content = const ShimmerMusicList();;
    // }

    content = LazyLoadScrollView(
        isLoading: isLoadingVertical,
        onEndOfPage: () => _loadMoreVertical(),
        child: StreamBuilder<SequenceState?>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data;
              final sequence = state?.sequence ?? [];
              return ListView.builder(
                  itemCount: sequence.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: MusicList(
                        mediaItem: state!.currentSource!.tag as MediaItem,
                      ),
                      onTap: () {},
                    );
                  });
            }
            return const ShimmerMusicList();
          },
          stream: audioState.player.sequenceStateStream,
        ));

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
          onPressed: () {},
        ),
        centerTitle: true,
        toolbarHeight: 60,
        title: Text(
          'WhatsApp Audio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: HexColor('#1e0b2b'),
            fontSize: 21,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: HexColor('#fefffe'),
                      width: double.infinity,
                      height: 50,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              margin: const EdgeInsets.only(left: 18),
                              width: 180,
                              height: 35,
                              decoration: BoxDecoration(
                                color: HexColor('#ac8bc9'),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_circle_fill,
                                    color: HexColor('#fefffe'),
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Shuffle Playback',
                                    style: TextStyle(
                                      color: HexColor('#fefffe'),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          IconButton(
                            highlightColor: Colors.black.withOpacity(0.02),
                            icon: Icon(
                              Icons.list_rounded,
                              size: 30,
                              color: HexColor('#8d8c8c'),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
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
              Container(
                color: Colors.blue,
                width: 30,
                height: double.infinity,
              )
            ],
          ),
        ),
        GestureDetector(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 25,
                        height: 45,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: dominantColor,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(100),
                                bottomRight: Radius.circular(100)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  // capitalizeEachWord(ref
                                  //     .watch(musikDimainkanProvider)
                                  //     .artist),
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              // ref.watch(musikDimainkanProvider).cover,
                              'https://picsum.photos/250?image=9',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {},
        )
      ]),
    );
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
