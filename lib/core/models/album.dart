class Album {
  String uid;
  String title;
  String image;
  String type;
  String author;
  String pin;
  String pinAt;
  String playedAt;
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
    required this.isEditable,
  });

  set setPin(String pin) {
    this.pin = pin;
  }
}
