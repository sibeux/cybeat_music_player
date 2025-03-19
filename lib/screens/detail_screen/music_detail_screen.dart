import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/appbar_title.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/codec_info.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/cover_detail_music.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/favorite_button.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/control_buttons.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/modal/detail_music_modal.dart';
import 'package:cybeat_music_player/widgets/detail_music_widget/title_artist_detail_music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../widgets/detail_music_widget/cover_blur.dart';
import '../../widgets/detail_music_widget/progress_bar_music.dart';

class MusicDetailScreen extends StatefulWidget {
  const MusicDetailScreen({
    super.key,
    required this.player,
    required this.audioState,
  });

  final AudioPlayer player;
  final AudioState audioState;

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  AudioPlayer get audioPlayer => widget.player;
  AudioState get audioState => widget.audioState;

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
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                // ClipRRect is used to clip the image to a rounded rectangle
                // awikwok banget nih, kalo ga pake ClipRRect, gambarnya bakal melebar melebihi ukuran layar.
                child: CoverBlur(),
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
            title: const AppbarTitle(),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () {
                  detailMusicModal(
                    context,
                    audioState
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // cover kecil
                const CoverDetailMusic(),
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const TitleArtistDetailMusic(),
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
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CodecInfo(),
                ),
                const SizedBox(
                  height: 20,
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
