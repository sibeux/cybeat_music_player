import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/database/favorite.dart';
import 'package:cybeat_music_player/providers/audio_source_state.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.player,
  });

  final AudioPlayer player;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final currentItem = context.watch<AudioSourceState>().audioSource;
    
    return Transform.scale(
          scale: 1.5,
          child: GestureDetector(
            onTap: () {
              if (currentItem?.tag.extras?['favorite'] == '1') {
                setfavorite(currentItem?.tag.extras?['music_id'], '0');
                currentItem?.tag.extras?['favorite'] = '0';
                showToast('Removed from favorite');
              } else {
                setfavorite(currentItem?.tag.extras?['music_id'], '1');
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
      }
  }

