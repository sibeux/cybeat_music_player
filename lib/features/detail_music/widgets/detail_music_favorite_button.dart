import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class DetailMusicFavoriteButton extends StatefulWidget {
  const DetailMusicFavoriteButton({
    super.key,
    required this.player,
  });

  final AudioPlayer player;

  @override
  State<DetailMusicFavoriteButton> createState() =>
      _DetailMusicFavoriteButtonState();
}

class _DetailMusicFavoriteButtonState extends State<DetailMusicFavoriteButton> {
  final DetailMusicController detailMusicController = Get.find<DetailMusicController>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SequenceState?>(
      stream: widget.player.sequenceStateStream,
      builder: (context, snapshot) {
        IndexedAudioSource? currentItem;

        if (snapshot.hasData) {
          currentItem = snapshot.data?.currentSource;
        }

        return Transform.scale(
          scale: 1.5,
          child: GestureDetector(
            onTap: () {
              if (currentItem?.tag.extras?['favorite'] == '1') {
                detailMusicController.setfavorite(currentItem?.tag.extras?['music_id'], '0');
                currentItem?.tag.extras?['favorite'] = '0';
                showToast('Removed from favorite');
              } else {
                detailMusicController.setfavorite(currentItem?.tag.extras?['music_id'], '1');
                currentItem?.tag.extras?['favorite'] = '1';
                showToast('Added to favorite');
              }
              setState(() {});
            },
            child: currentItem?.tag.extras?['favorite'] == '1'
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
        );
      },
    );
  }
}
