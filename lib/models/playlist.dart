class Playlist {
  String uid;
  String title;
  String image;
  String type;
  String artist;
  String pin;
  String datePin;
  String date;

  Playlist({
    required this.uid,
    required this.title,
    required this.image,
    required this.type,
    required this.artist,
    required this.pin,
    required this.datePin,
    required this.date,
  });

  set setPin(String pin) {
    this.pin = pin;
  }
}
