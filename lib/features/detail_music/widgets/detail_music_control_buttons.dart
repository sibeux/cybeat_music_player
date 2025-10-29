import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class DetailMusicControlButtons extends StatelessWidget {
  const DetailMusicControlButtons({
    super.key,
    required this.audioPlayer,
  });

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    final DetailMusicController detailMusicController = Get.find();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<LoopMode>(
          stream: audioPlayer.loopModeStream,
          builder: (context, snapshot) {
            return _repeatButton(context, snapshot.data ?? LoopMode.off);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.skip_previous,
            size: 30.sp,
            color: Colors.white,
          ),
          onPressed: () {
            detailMusicController.seekPreviousButton();
          },
        ),
        _playPauseButton(),
        IconButton(
          icon: Icon(
            Icons.skip_next,
            size: 30.sp,
            color: Colors.white,
          ),
          onPressed: () {
            detailMusicController.seekNextButton();
          },
        ),
        _shuffleButton(context)
      ],
    );
  }

  Widget _shuffleButton(BuildContext context) {
    final DetailMusicController detailMusicController = Get.find();
    return Obx(
      () => IconButton(
        icon: detailMusicController.isShuffleEnabled
            ? Icon(
                Icons.shuffle,
                color: Colors.lightBlueAccent,
                size: 30.sp,
              )
            : Icon(
                Icons.shuffle,
                color: Colors.white,
                size: 30.sp,
              ),
        onPressed: () {
          detailMusicController.toggleShuffleButton();
        },
      ),
    );
  }

  Widget _playPauseButton() {
    final DetailMusicController detailMusicController = Get.find();
    return Obx(() {
      if (detailMusicController.playerState == ProcessingState.loading ||
          detailMusicController.playerState == ProcessingState.buffering ||
          detailMusicController.isWaitingGetMusicStreamUrl) {
        return IconButton(
          iconSize: 60.sp,
          icon: Icon(
            Icons.play_circle_filled,
            color: Colors.grey,
          ),
          onPressed: () {},
        );
      }
      if (!detailMusicController.isMusicPlayingNow) {
        return IconButton(
          icon: const Icon(Icons.play_circle_fill),
          iconSize: 60.sp,
          color: const Color.fromRGBO(255, 255, 255, 1),
          onPressed: audioPlayer.play,
        );
      } else if (detailMusicController.playerState !=
              ProcessingState.completed ||
          (detailMusicController.isLastIndexMusic == false)) {
        return IconButton(
          icon: const Icon(Icons.pause_circle_filled),
          iconSize: 60.sp,
          color: Colors.white,
          onPressed: audioPlayer.pause,
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.replay),
          iconSize: 60.sp,
          color: Colors.white,
          onPressed: () => audioPlayer.seek(
            Duration.zero,
            index: audioPlayer.effectiveIndices.first,
          ),
        );
      }
    });
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat, color: Colors.white, size: 30.sp),
      Icon(Icons.repeat, color: Colors.amber, size: 30.sp),
      Icon(Icons.repeat_one, color: Colors.redAccent, size: 30.sp),
    ];

    final msg = [
      'Repeat off',
      'Repeat all',
      'Repeat one',
    ];

    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        showToast(msg[(index + 1) % msg.length]);
        audioPlayer.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }
}
