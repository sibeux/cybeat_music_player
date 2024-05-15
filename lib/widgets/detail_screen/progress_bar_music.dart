import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';

class ProgressBarMusic extends StatefulWidget {
  const ProgressBarMusic({
    super.key, required this.audioPlayer,
  });
  
  final AudioPlayer audioPlayer;

  @override
  State<ProgressBarMusic> createState() => _ProgressBarMusicState();
}

class _ProgressBarMusicState extends State<ProgressBarMusic> {

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

  AudioPlayer get audioPlayer => widget.audioPlayer;

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
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              widget.audioPlayer
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
      ],
    );
  }
}
