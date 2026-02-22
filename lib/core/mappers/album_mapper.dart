import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class AlbumMapper {
  static Album fromMap(Map<String, dynamic> item,
      {required int currentPinCount}) {
    final String type = (item['type'] ?? '').toString();

    // Logika penentuan author yang sebelumnya berantakan
    String authorText = _resolveAuthor(item);

    return Album(
      uid: item['id'].toString(),
      title: capitalizeEachWord(item['title'] ?? ''),
      image: item['cover'] == null ? '' : _formatImageUrl(item['cover']),
      type: type.capitalizeFirst ?? '',
      author: authorText,
      pin: item['pin_at'] != null ? 'true' : 'false',
      pinAt: item['pin_at'] ?? '',
      playedAt: item['played_at'] ?? item['created_at'] ?? '',
      isEditable: type == 'playlist' ? "true" : 'false',
    );
  }

  static String _resolveAuthor(Map<String, dynamic> item) {
    final type = item['type'];
    if (type == 'album') return capitalizeEachWord(item['author']);
    if (type == 'favorite') return 'jumlahFavorite Songs';
    if (type == 'category') return item['uid'] == '5' ? 'Total Songs' : 'ok';
    return capitalizeEachWord(item['author'] ?? 'Unknown Artist');
  }

  static String _formatImageUrl(String url) {
    return regexGdriveHostUrl(
      url: url,
      listApiKey: [],
      // gdriveApiKeyList, // Pastikan akses ke global variable ini aman
      isAudio: false,
    );
  }
}
