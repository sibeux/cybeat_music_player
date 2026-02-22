import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class AlbumMapper {
  static Album fromMap(Map<String, dynamic> item,
      {required int currentPinCount, required List<dynamic> gdriveApiKeyList}) {
    final String type = (item['type'] ?? '').toString();

    // Logika penentuan author yang sebelumnya berantakan
    String authorText = _resolveAuthor(item);
    final coverData = item['cover'];

    final finalCover = (coverData is String)
        ? {'default_cover': _formatImageUrl(coverData, gdriveApiKeyList)}
        : {
            ...{ for (var i in [1, 2, 3, 4]) 'cover_$i' : coverData['cover_$i'] != null
                  ? _formatImageUrl(coverData['cover_$i'], gdriveApiKeyList)
                  : "" },
            'total_non_null_cover': coverData['total_non_null_cover'],
          };

    return Album(
      uid: item['id'].toString(),
      title: capitalizeEachWord(item['title'] ?? ''),
      image: finalCover,
      type: type.capitalizeFirst ?? '',
      author: authorText,
      pin: item['pin_at'] != null ? 'true' : 'false',
      pinAt: item['pin_at'] ?? '',
      playedAt: item['played_at'] ?? '',
      createdAt: item['created_at'] ?? '',
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

  static String _formatImageUrl(String url, List<dynamic> gdriveApiKeyList) {
    return regexGdriveHostUrl(
      url: url,
      listApiKey: gdriveApiKeyList,
      isAudio: false,
    );
  }
}
