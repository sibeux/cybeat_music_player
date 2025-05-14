import 'dart:math';

String regexGdriveLink(
    {required String url, required List<dynamic> listApiKey}) {
  int randomIndex =
      Random().nextInt(listApiKey.length); // dari 0 sampai items.length - 1
  String key = listApiKey[randomIndex]['gdrive_api'];
  if (url.contains('drive.google.com')) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    return 'https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key';
  } else if (url.contains('www.googleapis.com')) {
    final regExp = RegExp(r'files\/([a-zA-Z0-9_-]+)\?');
    final match = regExp.firstMatch(url);
    return "https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key";
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
