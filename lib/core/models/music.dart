import 'package:cybeat_music_player/core/models/music_extras.dart';

class Music {
  final int musicId;
  final String linkDrive;
  final String title;
  final String artist;
  final String album;
  final String cover;
  final MusicExtras? extras;

  Music({
    required this.musicId,
    required this.linkDrive,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    this.extras,
  });
}
