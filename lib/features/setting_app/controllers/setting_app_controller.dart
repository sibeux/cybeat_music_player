import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SettingAppController extends GetxController {
  final AlbumService albumService = Get.find();
  final LogService logService = LogService.instance;

  bool get isSimpleMode => albumService.isSimpleMode.value;

  // State untuk Log Manager
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DateTime> availableLogDates = <DateTime>[].obs;
  final RxBool isLoadingLog = false.obs;
  final RxString currentLogContent = ''.obs;
  final RxString currentLogSize = '0 B'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAvailableLogs();
  }

  void toggleSimpleMode(bool value) {
    albumService.toggleSimpleMode(value);
  }

  /// Memuat daftar tanggal yang memiliki file log
  Future<void> loadAvailableLogs() async {
    try {
      final dates = await logService.getAvailableLogDates();
      availableLogDates.assignAll(dates);
      await checkSelectedDateLog();
    } catch (_) {}
  }

  /// Mengubah tanggal terpilih dan mengecek data lognya
  Future<void> selectDate(DateTime date) async {
    selectedDate.value = date;
    await checkSelectedDateLog();
  }

  /// Mengecek dan memuat konten / ukuran file log untuk tanggal terpilih
  Future<void> checkSelectedDateLog() async {
    isLoadingLog.value = true;
    try {
      final size = await logService.getLogFileSize(selectedDate.value);
      currentLogSize.value = size;

      final content = await logService.readLogContent(selectedDate.value);
      currentLogContent.value = content ?? '';
    } finally {
      isLoadingLog.value = false;
    }
  }

  /// Download / Share file log untuk tanggal yang dipilih
  Future<void> downloadOrShareLog({Rect? sharePositionOrigin}) async {
    final file = logService.getFileForDate(selectedDate.value);
    if (file == null || !await file.exists()) {
      Fluttertoast.showToast(
        msg: 'Tidak ada catatan log pada tanggal ${DateFormat('dd MMM yyyy').format(selectedDate.value)}',
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      return;
    }

    final success = await logService.shareLogFile(
      selectedDate.value,
      sharePositionOrigin: sharePositionOrigin,
    );

    if (!success) {
      Fluttertoast.showToast(
        msg: 'Gagal membagikan file log',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  /// Membuka Date Picker untuk memilih tanggal dalam batas 30 hari terakhir
  Future<void> pickLogDate(BuildContext context) async {
    final now = DateTime.now();
    final firstAllowedDate = now.subtract(const Duration(days: LogService.retentionDays - 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value.isAfter(firstAllowedDate) ? selectedDate.value : now,
      firstDate: DateTime(firstAllowedDate.year, firstAllowedDate.month, firstAllowedDate.day),
      lastDate: DateTime(now.year, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8238BE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E0B2B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await selectDate(picked);
    }
  }
}
