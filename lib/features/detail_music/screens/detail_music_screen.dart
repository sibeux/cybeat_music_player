import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_appbar_title.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_codec_info.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_cover_image.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_favorite_button.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_control_buttons.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_modal.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_title_artist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/detail_music_background_blur.dart';
import '../widgets/detail_music_progress_bar.dart';

class DetailMusicScreen extends StatefulWidget {
  const DetailMusicScreen({
    super.key,
  });

  @override
  State<DetailMusicScreen> createState() => _DetailMusicScreenState();
}

class _DetailMusicScreenState extends State<DetailMusicScreen> {
  final audioStateController = Get.find<AudioStateController>();

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
                child: DetailMusicBackgroundBlur(),
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
            title: const DetailMusicAppbarTitle(),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () {
                  detailMusicModal(context, audioStateController);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // cover kecil
                const DetailMusicCoverImage(),
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const DetailMusicTitleArtist(),
                      const SizedBox(
                        width: 15,
                      ),
                      DetailMusicFavoriteButton(
                        player: audioStateController.activePlayer.value!,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DetailMusicCodecInfo(),
                ),
                const SizedBox(
                  height: 20,
                ),
                // to create one straight line
                // child: Divider(
                //   color: Colors.white,
                //   thickness: 1,
                DetailMusicProgressBarMusic(
                    audioPlayer: audioStateController.activePlayer.value!),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: DetailMusicControlButtons(
                      audioPlayer: audioStateController.activePlayer.value!),
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
