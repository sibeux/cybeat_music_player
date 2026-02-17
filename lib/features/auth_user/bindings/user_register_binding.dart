import 'package:cybeat_music_player/features/auth_user/controllers/user_login_controller.dart';
import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:get/get.dart';

class UserRegisterBinding extends Bindings {
  @override
  void dependencies() {
    /// [Get.put] dengan [permanent: true]
    /// Digunakan karena UserRegisterController menyimpan data input (state) yang harus
    /// dibawa dari Screen 1 ke Screen 2.
    /// Status 'permanent' mencegah GetX menghapus controller ini saat Screen 1 di-off,
    /// sehingga variabel di dalamnya tidak ter-reset.
    /// Wajib dihapus manual di Screen terakhir menggunakan Get.delete(force: true).
    Get.put(UserRegisterController(), permanent: true);

    /// [Get.lazyPut] dengan [fenix: true]
    /// Digunakan untuk controller yang bersifat mendukung (logic-only) dan tidak
    /// masalah jika instance-nya terhapus & dibuat ulang (resurrect).
    /// Jika Screen 1 ditutup, instance ini dihapus dari RAM untuk efisiensi,
    /// tapi GetX tetap ingat cara membuatnya kembali jika Screen 2 memanggilnya.
    Get.lazyPut<UserLoginController>(() => UserLoginController(), fenix: true);
  }
}
