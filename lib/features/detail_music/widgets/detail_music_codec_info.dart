import 'package:cybeat_music_player/controller/music_play/read_codec_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailMusicCodecInfo extends StatelessWidget {
  const DetailMusicCodecInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final readCodecController = Get.find<ReadCodecController>();
    return Obx(
      () => Text(
        '${readCodecController.sampleRate.value} kHz | ${readCodecController.bitsPerRawSample.value} bits | ${readCodecController.bitRate.value} kbps',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
