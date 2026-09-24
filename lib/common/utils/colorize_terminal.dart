import 'package:cybeat_music_player/core/services/log_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode

String _formatConsoleLog(String level, String text) {
  final now = DateTime.now();
  final timestamp =
      "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}."
      "${now.millisecond.toString().padLeft(3, '0')}";
  return '[$timestamp] [$level] $text';
}

void _printColor(String level, String text, String colorCode) {
  // Hanya print warna jika sedang dalam mode debug
  if (kDebugMode) {
    final formatted = _formatConsoleLog(level, text);
    debugPrint('$colorCode$formatted\x1B[0m');
  }
}

void logSuccess(String text) {
  _printColor('SUCCESS', text, '\x1B[32m'); // Hijau
  FirebaseCrashlytics.instance.log('SUCCESS: $text');
  LogService.instance.writeLog('SUCCESS', text);
}

void logError(String text, {dynamic error, StackTrace? stack}) {
  _printColor('ERROR', text, '\x1B[31m'); // Merah

  // Kirim ke Crashlytics sebagai non-fatal error
  FirebaseCrashlytics.instance.recordError(
    error ?? Exception(text),
    stack ?? StackTrace.current,
    reason: text,
    fatal: false,
  );

  // Simpan ke offline log file
  LogService.instance.writeLog(
    'ERROR',
    text,
    error: error,
    stackTrace: stack,
  );
}

void logWarning(String text) {
  _printColor('WARN', text, '\x1B[35m'); // Ungu
  FirebaseCrashlytics.instance.log('WARN: $text');
  LogService.instance.writeLog('WARN', text);
}

void logInfo(String text) {
  _printColor('INFO', text, '\x1B[37m'); // Putih/Abu
  FirebaseCrashlytics.instance.log('INFO: $text');
  LogService.instance.writeLog('INFO', text);
}

