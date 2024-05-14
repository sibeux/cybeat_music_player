import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/database/favorite.dart';
import 'package:cybeat_music_player/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

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
            // Shimmer.fromColors(
            //   baseColor: Colors.grey.shade300,
            //   highlightColor: Colors.grey.shade100,
            //   child: Container(
            //     color: Colors.black,
            //   ),
            // ),
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
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
                        return CachedNetworkImage(
                          imageUrl: currentItem!.tag.artUri.toString(),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          color: Colors.black.withOpacity(0.5),
                          memCacheHeight: 20,
                          memCacheWidth: 20,
                          colorBlendMode: BlendMode.darken,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Container(
                            color: Colors.black,
                          ),
                          errorWidget: (context, exception, stackTrace) {
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      // cover kecil
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: currentItem!.tag.artUri.toString(),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              memCacheHeight: 500,
                              memCacheWidth: 500,
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return Image.asset(
                                  'assets/images/placeholder_cover_music.png',
                                  fit: BoxFit.cover,
                                );
                              },
                              errorWidget: (context, exception, stackTrace) {
                                return Image.asset(
                                  'assets/images/placeholder_cover_music.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /*Text(
                                    capitalizeEachWord(currentItem.tag.title),
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.values[5],
                                    ),
                                  ),*/
                                  SizedBox(
                                    height: 30,
                                    child: Marquee(
                                      text: capitalizeEachWord(
                                          currentItem.tag.title),
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.values[5],
                                      ),
                                      scrollAxis: Axis.horizontal,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // spacing end of text
                                      blankSpace: 30,
                                      // second needed before slide again
                                      pauseAfterRound: const Duration(seconds: 5),
                                      // text gonna slide first time after this second
                                      startAfter: const Duration(seconds: 5),
                                      decelerationCurve: Curves.easeOut,
                                      // speed of slide text
                                      velocity: 35,
                                      accelerationCurve: Curves.linear,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    capitalizeEachWord(
                                        currentItem.tag.artist ?? ''),
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Transform.scale(
                              scale: 1.5,
                              child: GestureDetector(
                                onTap: () {
                                  if (currentItem.tag.extras?['favorite'] ==
                                      '1') {
                                    setfavorite(
                                        currentItem.tag.extras?['music_id'],
                                        '0');
                                    currentItem.tag.extras?['favorite'] = '0';
                                    showToast('Removed from favorite');
                                  } else {
                                    setfavorite(
                                        currentItem.tag.extras?['music_id'],
                                        '1');
                                    currentItem.tag.extras?['favorite'] = '1';
                                    showToast('Added to favorite');
                                  }
                                  setState(() {});
                                },
                                child:
                                    currentItem.tag.extras?['favorite'] == '1'
                                        ? const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 30,
                                          )
                                        : const Icon(
                                            Icons.star_outline_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      // to create one straight line
                      // child: Divider(
                      //   color: Colors.white,
                      //   thickness: 1,
                      SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 1,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 10),
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
                            audioPlayer
                                .seek(Duration(milliseconds: position.round()));
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        padding: const EdgeInsets.all(0.0),
                        child: ControlButtons(audioPlayer: audioPlayer),
                      ),
                      const SizedBox(
                        // buat ngatur jarak antara control buttons
                        // dan bottom navigation
                        height: 35,
                      ),
                    ],
                  ),
                );
              }),
        )
      ],
    );
  }
}
