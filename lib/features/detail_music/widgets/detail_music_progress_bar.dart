import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';

class DetailMusicProgressBarMusic extends StatefulWidget {
  const DetailMusicProgressBarMusic({
    super.key,
    required this.audioPlayer,
  });

  final AudioPlayer audioPlayer;

  @override
  State<DetailMusicProgressBarMusic> createState() =>
      _DetailMusicProgressBarMusicState();
}

class _DetailMusicProgressBarMusicState
    extends State<DetailMusicProgressBarMusic> {
  Duration? duration;
  Duration? position;
  Duration? buffered;

  // --- TAMBAHKAN STATE BARU ---
  bool _isSeeking = false;
  Duration? _dragValue;
  // ---------------------------

  String formatDuration(Duration? duration) {
    if (duration == null) return 'buffering';
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedSubscription;

  // --- MODIFIKASI GETTER ---
  // Gunakan _dragValue jika sedang seeking, jika tidak gunakan position dari stream
  String get _positionText =>
      formatDuration(_isSeeking ? _dragValue : position);
  // -------------------------

  String get _durationText => formatDuration(duration);

  AudioPlayer get audioPlayer => widget.audioPlayer;

  @override
  void initState() {
    _durationSubscription = audioPlayer.durationStream.listen((event) {
      setState(() {
        duration = event;
      });
    });

    _bufferedSubscription = audioPlayer.bufferedPositionStream.listen((event) {
      setState(() {
        buffered = event;
      });
    });

    _positionSubscription = audioPlayer.positionStream.listen((event) {
      // --- MODIFIKASI LISTENER ---
      // Hanya update posisi jika pengguna tidak sedang menggeser slider
      if (!_isSeeking) {
        setState(() {
          position = event;
        });
      }
      // ---------------------------
    });

    super.initState();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- TAMBAHKAN LOGIKA UNTUK NILAI SLIDER ---
    final sliderValue = (_isSeeking ? _dragValue : position) ?? Duration.zero;
    final totalDuration = duration ?? Duration.zero;
    // ------------------------------------------

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 1.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
          ),
          child: Slider(
            // --- MODIFIKASI VALUE SLIDER ---
            value: (sliderValue.inMilliseconds > 0 &&
                    totalDuration.inMilliseconds > 0 &&
                    sliderValue.inMilliseconds < totalDuration.inMilliseconds)
                ? sliderValue.inMilliseconds / totalDuration.inMilliseconds
                : 0.0,
            // -------------------------------
            secondaryTrackValue: (buffered != null &&
                    duration != null &&
                    buffered!.inMilliseconds > 0 &&
                    buffered!.inMilliseconds < duration!.inMilliseconds)
                ? buffered!.inMilliseconds / duration!.inMilliseconds
                : 0.0,
            activeColor: HexColor('#fefffe'),
            secondaryActiveColor: HexColor('#ac8bc9'),
            inactiveColor: HexColor('#726878'),
            // --- MODIFIKASI ONCHANGED DAN TAMBAHKAN CALLBACK BARU ---
            onChangeStart: (value) {
              setState(() {
                _isSeeking = true;
              });
            },
            onChanged: (value) {
              setState(() {
                final newPosition = value * (duration?.inMilliseconds ?? 0);
                _dragValue = Duration(milliseconds: newPosition.round());
              });
            },
            onChangeEnd: (value) async {
              // 1. Jadikan method ini async
              // Hapus Future.delayed
              // Future.delayed(const Duration(milliseconds: 200), () {
              //    setState(() {
              //      _isSeeking = false;
              //    });
              // });

              final durasi = duration;
              if (durasi == null) {
                return;
              }

              final position = value * durasi.inMilliseconds;
              widget.audioPlayer.seek(Duration(milliseconds: position.round()));

              // 3. Setelah selesai, baru update state
              setState(() {
                _isSeeking = false;
              });
            },
            // --------------------------------------------------------
          ),
        ),
        SizedBox(height: 3.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _positionText, // Teks ini sekarang juga akan update saat dragging
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                _durationText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
