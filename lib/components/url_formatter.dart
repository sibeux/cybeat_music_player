import 'dart:math';

String regexGdriveHostUrl(
    {required String url, required List<dynamic> listApiKey}) {
  // Filter hanya yang email-nya mengandung @gmail.com
  final gmailOnly = listApiKey.where((item) {
    final email = item['email']?.toString() ?? '';
    return email.contains('@gmail.com');
  }).toList();

  if (gmailOnly.isEmpty) return '';

  final randomIndex = Random().nextInt(gmailOnly.length);
  String key = gmailOnly[randomIndex]['gdrive_api'];
  if (key.isEmpty) {
    key = gmailOnly[0]['gdrive_api'];
  }

  if (url.contains('drive.google.com')) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    // return 'https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key';
    return "https://sibeux.my.id/cloud-music-player/api/stream_drive?fileId=${match!.group(1)}";
  } else if (url.contains('www.googleapis.com')) {
    final regExp = RegExp(r'files\/([a-zA-Z0-9_-]+)\?');
    final match = regExp.firstMatch(url);
    // return "https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key";
    return "https://sibeux.my.id/cloud-music-player/api/stream_drive?fileId=${match!.group(1)}";
  } else if (url.contains('https://github.com/') && url.contains('raw=true')) {
    return url
        .replaceFirst(
            "https://github.com/", "https://raw.githubusercontent.com/")
        .replaceFirst("/blob/", "/refs/heads/")
        .split('?')
        .first; // menghapus query string
  } else {
    return url;
  }
}
