class Music {
  final int musicId;
  final String linkDrive;
  final String title;
  final String artist;
  final String album;
  final String cover;
  final Map<String, dynamic> extras;

  Music({
    required this.musicId,
    required this.linkDrive,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.extras,
  });
}
