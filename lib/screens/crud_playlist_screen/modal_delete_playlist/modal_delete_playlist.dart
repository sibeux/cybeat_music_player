import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/controller/crud_playlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void showModalDeletePlaylist(
  BuildContext context,
  String title,
  String uid,
  String type,
) {
  showCupertinoDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Delete Playlist'),
      content: Text('Are you sure you want to delete "$title"?'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () {
            Get.back();
          },
          child: const Text('No'),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Get.back();
            deletePlaylist(uid);
            showRemoveAlbumToast(
              '${type.capitalizeFirst!} removed from your library',
            );
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}
