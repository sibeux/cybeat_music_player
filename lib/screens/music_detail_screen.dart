import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/widgets/capitalize.dart';
import 'package:cybeat_music_player/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';

class MusicDetailScreen extends StatefulWidget {
  const MusicDetailScreen({
    super.key,
    required this.player,
    required this.mediaItem,
  });

  final AudioPlayer player;
  final MediaItem mediaItem;

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  Duration? duration;
  Duration? position;

  String formatDuration(Duration? duration) {
    if (duration == null) return 'buffering';
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  String get _durationText => formatDuration(duration);

  String get _positionText => formatDuration(position);

  AudioPlayer get audioPlayer => widget.player;

  MediaItem get mediaItem => widget.mediaItem;

  @override
  void initState() {
    _durationSubscription = audioPlayer.durationStream.listen((event) {
      setState(() {
        duration = event;
      });
    });

    _positionSubscription = audioPlayer.positionStream.listen((event) {
      setState(() {
        position = event;
      });
    });

    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                // ClipRRect is used to clip the image to a rounded rectangle
                // awikwok banget nih, kalo ga pake ClipRRect, gambarnya bakal melebar melebihi ukuran layar
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaY: 35,
                    sigmaX: 35,
                  ),
                  child: StreamBuilder<SequenceState?>(
                    stream: audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final currentItem = snapshot.data?.currentSource;
                        return Image.network(
                          currentItem!.tag.artUri.toString(),
                          scale: 5,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          color: Colors.black.withOpacity(0.5),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, exception, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 126, 248, 60),
                                    Color.fromARGB(255, 253, 123, 123),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 35,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: StreamBuilder(
              stream: audioPlayer.sequenceStateStream,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const CircularProgressIndicator();
                }
                final currentItem = snapshot.data?.currentSource;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: 340,
                          height: 350,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              currentItem!.tag.artUri.toString(),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer(
                                  gradient: const LinearGradient(
                                    colors: [Colors.grey, Colors.white],
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              errorBuilder: (context, exception, stackTrace) {
                                return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey,
                                    child: const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white,
                                      size: 50,
                                    ));
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          capitalizeEachWord(currentItem.tag.title),
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.values[5],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          capitalizeEachWord(currentItem.tag.artist ?? ''),
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        // to create one straight line
                        // child: Divider(
                        //   color: Colors.white,
                        //   thickness: 1,
                        child: SliderTheme(
                          data: const SliderThemeData(
                            trackHeight: 1,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 20),
                          ),
                          child: Slider(
                            value: (position != null &&
                                    duration != null &&
                                    position!.inMilliseconds > 0 &&
                                    position!.inMilliseconds <
                                        duration!.inMilliseconds)
                                ? position!.inMilliseconds /
                                    duration!.inMilliseconds
                                : 0.0,
                            activeColor: HexColor('#fefffe'),
                            inactiveColor: HexColor('#726878'),
                            onChanged: (value) {
                              final durasi = duration;
                              if (durasi == null) {
                                return;
                              }
                              final position = value * durasi.inMilliseconds;
                              audioPlayer.seek(
                                  Duration(milliseconds: position.round()));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _positionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _durationText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ControlButtons(audioPlayer: audioPlayer),
                      ),
                    ],
                  ),
                );
              }),
        )
      ],
    );
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
