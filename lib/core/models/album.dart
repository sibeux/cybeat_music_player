class Album {
  String uid;
  String title;
  Map<String, Object?> image;
  String type;
  String author;
  String pin;
  String pinAt;
  String playedAt;
  String createdAt;
  String isEditable;

  Album({
    required this.uid,
    required this.title,
    required this.image,
    required this.type,
    required this.author,
    required this.pin,
    required this.pinAt,
    required this.playedAt,
    required this.createdAt,
    required this.isEditable,
  });

  set setPin(String pin) {
    this.pin = pin;
  }
}
