class Music {
  const Music(
      {required this.id,
      required this.title,
      required this.artist,
      required this.album,
      required this.cover,
      required this.url,
      required this.duration,
      required this.isFavorite});

  final String id;
  final String title;
  final String artist;
  final String album;
  final String cover;
  final String url;
  final String duration;
  final String isFavorite;
}
