import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode

void _printColor(String text, String colorCode) {
  // Hanya print warna jika sedang dalam mode debug
  if (kDebugMode) {
    debugPrint('$colorCode$text\x1B[0m');
  }
}

void logSuccess(String text) {
  _printColor(text, '\x1B[32m'); // Hijau
  FirebaseCrashlytics.instance.log('SUCCESS: $text');
}

void logError(String text, {dynamic error, StackTrace? stack}) {
  _printColor('ERROR: $text', '\x1B[31m'); // Merah

  // Kirim ke Crashlytics sebagai non-fatal error
  FirebaseCrashlytics.instance.recordError(
    error ?? Exception(text),
    stack ?? StackTrace.current,
    reason: text,
    fatal: false,
  );
}

void logWarning(String text) {
  _printColor('WARNING: $text', '\x1B[35m'); // Ungu
  FirebaseCrashlytics.instance.log('WARN: $text');
}

void logInfo(String text) {
  _printColor('INFO: $text', '\x1B[37m'); // Putih/Abu
  FirebaseCrashlytics.instance.log('INFO: $text');
}
