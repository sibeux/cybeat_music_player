import 'package:cybeat_music_player/models/playlist.dart';
import 'package:get/get.dart';

class HomeAlbumGridController extends GetxController {
  var children = RxList([]);
  var selectedAlbum = RxList<Playlist?>([]);
  var isTapped = false.obs;

  void updateChildren(List<Playlist> playlist) {
    children.value = List.generate(
      playlist.length,
      (index) => index,
    );
    selectedAlbum.value = List.generate(
      playlist.length,
      (index) => playlist[index],
    );
  }

  void pinAlbum(String uid) {
    final index = selectedAlbum.indexWhere((element) => element?.uid == uid);
    final currentChild = children[index]; // Simpan elemen dari indeks index
    final currentAlbum = selectedAlbum[index]; // Simpan elemen dari indeks index
    children.removeAt(index); // Hapus elemen dari indeks index
    selectedAlbum.removeAt(index); // Hapus elemen dari indeks index
    children.insert(0, currentChild); // Sisipkan kembali elemen ke indeks 0
    selectedAlbum.insert(0, currentAlbum); // Sisipkan kembali elemen ke indeks 0

    isTapped.value = !isTapped.value;
  }
}
