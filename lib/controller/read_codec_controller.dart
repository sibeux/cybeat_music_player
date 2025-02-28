import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ReadCodecController extends GetxController {
  var sampleRate = ''.obs;
  var bitsPerRawSample = ''.obs;
  var bitRate = ''.obs;

  Future<void> onReadCodec(String url) async {
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
        debugPrint('Error: Response body is empty');
        return;
      }

      final responseBody = jsonDecode(response.body);

      sampleRate.value = responseBody["streams"][0]["sample_rate"] ?? '';
      bitsPerRawSample.value =
          responseBody["streams"][0]["bits_per_raw_sample"] ?? '';
      bitRate.value = responseBody["format"]["bit_rate"] ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Error onReadCodec: $e');
      }
    }
  }
}
