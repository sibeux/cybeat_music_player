import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortPreferencesController extends GetxController {
  final sort = ''.obs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  SortPreferencesController() {
    getSortBy();
  }

  Future<void> saveSortBy(String value) async {
    final SharedPreferences prefs = await _prefs;
    
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

  get sortValue => sort.value;
}
