class Playlist {
  String uid;
  String title;
  String image;
  String type;
  String pin;
  String date;

  Playlist({
    required this.uid,
    required this.title,
    required this.image,
    required this.type,
    required this.pin,
    required this.date,
  });

  set setPin(String pin) {
    this.pin = pin;
  }
}
