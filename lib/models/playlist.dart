class Playlist {
  String uid;
  String title;
  String image;
  String type;
  String author;
  String pin;
  String datePin;
  String date;
  String editable;

  Playlist({
    required this.uid,
    required this.title,
    required this.image,
    required this.type,
    required this.author,
    required this.pin,
    required this.datePin,
    required this.date,
    required this.editable,
  });

  set setPin(String pin) {
    this.pin = pin;
  }
}
