import 'dart:math';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';

String regexGdriveHostUrl({
  required String url,
  required List<dynamic> listApiKey,
  bool isAudio = true,
  bool isAudioCached = false,
  String musicId = '',
}) {
  // Filter hanya yang email-nya mengandung @gmail.com
  final gmailOnly = listApiKey.where((item) {
    final email = item['email']?.toString() ?? '';
    return email.contains('@gmail.com');
  }).toList();

  if (gmailOnly.isEmpty) {
    logError('Tidak ada API Key yang valid ditemukan.');
    return '';
  }

  final randomIndex = Random().nextInt(gmailOnly.length);
  String key = gmailOnly[randomIndex]['gdrive_api'];
  // Regex tunggal untuk menangkap ID dari kedua format URL Google Drive
  /// Dibuat satu RegExp yang lebih cerdas menggunakan operator | (atau).
  /// Regex r'/d/([a-zA-Z0-9_-]+)|files/([a-zA-Z0-9_-]+)' akan mencari-
  /// ID file baik yang diawali /d/ maupun files/
  final googleDriveRegex =
      RegExp(r'/d/([a-zA-Z0-9_-]+)|files/([a-zA-Z0-9_-]+)');
  final match = googleDriveRegex.firstMatch(url);
  final cacheEndpoint = listApiKey.where((item) {
    final email = item['email']?.toString() ?? '';
    return email == 'cybeat_cache_url';
  }).toList();

  if (match != null) {
    // Ambil ID dari grup yang cocok (grup 1 atau grup 2)
    final fileId = match.group(1) ?? match.group(2);

    if (isAudio) {
      if (isAudioCached) {
        return "${cacheEndpoint.first['gdrive_api']}/$fileId";
      } else {
        return "https://sibeux.my.id/cloud-music-player/api/stream/$fileId/$musicId";
      }
    } else {
      return 'https://www.googleapis.com/drive/v3/files/$fileId?alt=media&key=$key';
    }
  } else if (url.contains('https://github.com/') && url.contains('raw=true')) {
    // Logika GitHub tetap sama karena unik
    return url
        .replaceFirst(
            "https://github.com/", "https://raw.githubusercontent.com/")
        .replaceFirst("/blob/",
            "/refs/heads/") // Perbaikan kecil: "/blob/" menjadi "/" saja
        .split('?')
        .first;
  } else {
    // Fallback jika tidak ada format URL yang cocok
    return url;
  }
}
