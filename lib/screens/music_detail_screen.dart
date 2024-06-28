import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/widgets/detail_screen/appbar_title.dart';
import 'package:cybeat_music_player/widgets/detail_screen/cover_detail_music.dart';
import 'package:cybeat_music_player/widgets/detail_screen/favorite_button.dart';
import 'package:cybeat_music_player/widgets/detail_screen/control_buttons.dart';
import 'package:cybeat_music_player/widgets/detail_screen/title_artist_detail_music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/detail_screen/cover_blur.dart';
import '../widgets/detail_screen/progress_bar_music.dart';

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
  AudioPlayer get audioPlayer => widget.player;

  MediaItem get mediaItem => widget.mediaItem;

  @override
  void initState() {
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
                child: CoverBlur(
                  player: audioPlayer,
                ),
              ),
            )
          ],
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            toolbarHeight: 70,
            leading: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 35,
                color: Colors.white,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            title: AppbarTitle(
              player: audioPlayer,
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // cover kecil
                CoverDetailMusic(
                  player: audioPlayer,
                ),
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      TitleArtistDetailMusic(player: audioPlayer),
                      const SizedBox(
                        width: 15,
                      ),
                      FavoriteButton(
                        player: audioPlayer,
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
                ProgressBarMusic(audioPlayer: audioPlayer),
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
          ),
        )
      ],
    );
  }
}
