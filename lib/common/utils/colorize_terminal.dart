import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

void logSuccess(String text) {
  debugPrint('\x1B[32m$text\x1B[0m');
  FirebaseCrashlytics.instance.log(text);
}

void logError(String text) {
  debugPrint('\x1B[31m$text\x1B[0m');
  FirebaseCrashlytics.instance.recordError(Exception(text), StackTrace.current,
      reason: text, fatal: false);
}

void logInfo(String text) {
  debugPrint('\x1B[33m$text\x1B[0m');
  FirebaseCrashlytics.instance.log(text);
}
