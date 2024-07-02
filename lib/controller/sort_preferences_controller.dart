import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortPreferencesController extends GetxController {
  final sort = ''.obs;
  final isTapSort = false.obs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  
  @override
  void onInit() {
    super.onInit();
    getSortBy();
  }

  Future<void> saveSortBy(String value) async {
    final SharedPreferences prefs = await _prefs;
    isTapSort.value = !isTapSort.value;

    switch (value) {
      case 'Recents':
        sort.value = 'uid';
        prefs.setString('sort', 'uid');
        break;
      case 'Alphabetical':
        prefs.setString('sort', 'title');
        sort.value = 'title';
        break;
    }
  }

  Future<void> getSortBy() async {
    final SharedPreferences prefs = await _prefs;
    final sort = prefs.getString('sort') ?? 'uid';
    this.sort.value = sort;
  }

  get sortValueFromShared async {
    final SharedPreferences prefs = await _prefs;
    final sort = prefs.getString('sort') ?? 'uid';
    return sort;
  }

  get sortValue => sort.value;
}
