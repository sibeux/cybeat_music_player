import 'dart:convert';

import 'package:cybeat_music_player/components/colorize_terminal.dart';
import 'package:http/http.dart' as http;

Future<void> uploadHostMusic(
    {required String musicUri, required String musicId}) async {
  const uri =
      "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/music_host_upload";

  try {
    // HEAD request
    final headExtRequest = await http.head(Uri.parse(musicUri));
    if (headExtRequest.statusCode != 200) {
      logError('Gagal ambil header, status: ${headExtRequest.statusCode}');
      return;
    }

    String? contentType = headExtRequest.headers['content-type'];
    if (contentType == null) {
      logError('Content-Type tidak ditemukan');
      return;
    }

    String fileExt;

    // cek kalau audio
    if (contentType.startsWith('audio/')) {
      // ambil bagian setelah /
      fileExt = contentType.split('/')[1];
      // hapus prefix x- atau vnd.
      fileExt = fileExt.replaceAll(RegExp(r'^(x-|vnd\.)'), '');
    } else {
      // fallback
      fileExt = 'bin';
    }

    logInfo('MIME: $contentType, ekstensi: $fileExt');

    final response = await http.post(Uri.parse(uri), body: {
      'file_url': musicUri,
      'file_name': musicId,
      'file_ext': fileExt,
    });

    if (response.statusCode != 200 || response.body.isEmpty) {
      logError('Failed uploadHostMusic: Response body: ${response.body}');
      return;
    }

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['status'] != 'success') {
      logError('API returned non-success in uploadHostMusic with status: $body}');
      return;
    }

    logSuccess('Successfully uploaded music host: $body');
  } catch (e) {
    logError('error uploadHostMusic: $e');
  }
}
