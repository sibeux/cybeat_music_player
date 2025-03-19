import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class ProgressMusicController extends GetxController {
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  final AudioPlayer player;

  ProgressMusicController({required this.player});

  @override
  void onInit() {
    super.onInit();
    // Subscribe ke stream dan perbarui durasi.
    player.durationStream.listen((event) {
      updateDuration(event);
    });

    // Subscribe ke stream dan perbarui posisi.
    player.positionStream.listen((event) {
      updatePosition(event);
    });
  }

  /*
  untuk kasus stream durasi dan posisi, tidak perlu pakai onclose,
  karena akan selalu ada perubahan durasi dan posisi,
  sehingga tidak perlu di-dispose.

  Akibatnya jika ada subscription dan di-close,
  maka progress bar tidak akan berjalan, karena stream sudah di-close.
  */

  void updateDuration(Duration? duration) {
    // pakai this karena nama parameter sama dengan nama variabel
    this.duration.value = duration ?? Duration.zero;
  }

  void updatePosition(Duration? position) {
    this.position.value = position ?? Duration.zero;
  }
}
