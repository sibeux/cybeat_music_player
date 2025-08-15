import 'dart:convert';

import 'package:cybeat_music_player/components/colorize_terminal.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ReadCodecController extends GetxController {
  var sampleRate = '--'.obs;
  var bitsPerRawSample = '--'.obs;
  var bitRate = '--'.obs;

  Future<void> onReadCodec(String url) async {
    sampleRate.value = '--';
    bitsPerRawSample.value = '--';
    bitRate.value = '--';

    const uri =
        "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/read_codec.php";

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'url': url,
        },
      );

      if (response.body.isEmpty) {
        logError('Error onReadCodec: Response body is empty');
        return;
      }

      final responseBody = jsonDecode(response.body);

      bitsPerRawSample.value =
          responseBody["streams"][0]["bits_per_raw_sample"] ?? '--';
      final String fileSampleRate =
          responseBody["streams"][0]["sample_rate"] ?? '--';
      final String fileBitRate = responseBody["format"]["bit_rate"] ?? '--';

      sampleRate.value = fileSampleRate != '--'
          ? (int.parse(fileSampleRate) / 1000).toString()
          : '--';
      bitRate.value = fileBitRate != '--'
          ? (int.parse(fileBitRate) / 1000).toStringAsFixed(0)
          : '--';
    } catch (e) {
      logError('Error onReadCodec: $e');
    }
  }
}
