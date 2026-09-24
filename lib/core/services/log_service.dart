import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LogService {
  LogService._();
  static final LogService instance = LogService._();

  static const int retentionDays = 30;
  static const String _logDirName = 'app_logs';
  static const String _logFilePrefix = 'cybeat_log_';

  Directory? _logDirectory;
  final DateFormat _fileDateFormat = DateFormat('yyyy-MM-dd');

  // Sequential write queue to prevent concurrent file write conflicts
  Completer<void>? _writeQueue;

  bool _isInitialized = false;

  /// Inisialisasi direktori log dan bersihkan log > 30 hari
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _logDirectory = Directory(p.join(appDocDir.path, _logDirName));

      if (!await _logDirectory!.exists()) {
        await _logDirectory!.create(recursive: true);
      }

      await cleanOldLogs();
      _isInitialized = true;
    } catch (e) {
      debugPrint('LogService init error: $e');
    }
  }

  /// Format nama file berdasarkan tanggal: cybeat_log_YYYY-MM-DD.txt
  String _getFileNameForDate(DateTime date) {
    final dateStr = _fileDateFormat.format(date);
    return '$_logFilePrefix$dateStr.txt';
  }

  /// Mendapatkan File log untuk tanggal tertentu
  File? getFileForDate(DateTime date) {
    if (_logDirectory == null) return null;
    final filePath = p.join(_logDirectory!.path, _getFileNameForDate(date));
    return File(filePath);
  }

  /// Menulis entri log baru ke file hari ini (Offline support)
  void writeLog(
    String level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    // Jalankan secara asynchronous tanpa memblokir thread pemanggil
    _enqueueWrite(() async {
      try {
        if (!_isInitialized || _logDirectory == null) {
          await init();
        }

        final now = DateTime.now();
        final file = getFileForDate(now);
        if (file == null) return;

        final buffer = StringBuffer();
        final timestampStr =
            "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}."
            "${now.millisecond.toString().padLeft(3, '0')}";
        buffer.write('[$timestampStr] [$level] $message\n\n');

        if (error != null) {
          buffer.write('  Exception/Error: $error\n\n');
        }

        if (stackTrace != null) {
          buffer.write('  StackTrace:\n$stackTrace\n\n');
        }

        await file.writeAsString(
          buffer.toString(),
          mode: FileMode.append,
          flush: true,
        );
      } catch (e) {
        debugPrint('LogService write error: $e');
      }
    });
  }

  /// Antrean penulisan log agar urut dan tidak terjadi race condition pada I/O file
  void _enqueueWrite(Future<void> Function() writeAction) {
    final previousQueue = _writeQueue;
    final newCompleter = Completer<void>();
    _writeQueue = newCompleter;

    if (previousQueue != null && !previousQueue.isCompleted) {
      previousQueue.future.whenComplete(() async {
        try {
          await writeAction();
        } finally {
          newCompleter.complete();
        }
      });
    } else {
      writeAction().whenComplete(() {
        newCompleter.complete();
      });
    }
  }

  /// Menghapus file log yang usianya lebih dari [retentionDays] (30 hari)
  Future<void> cleanOldLogs() async {
    try {
      if (_logDirectory == null || !await _logDirectory!.exists()) return;

      final thresholdDate = DateTime.now().subtract(const Duration(days: retentionDays));
      final files = _logDirectory!.listSync();

      for (final entity in files) {
        if (entity is File && p.basename(entity.path).startsWith(_logFilePrefix)) {
          final fileName = p.basenameWithoutExtension(entity.path);
          final datePart = fileName.replaceFirst(_logFilePrefix, '');
          try {
            final fileDate = _fileDateFormat.parse(datePart);
            // Jika tanggal file lebih lama dari batas retention 30 hari
            if (fileDate.isBefore(DateTime(thresholdDate.year, thresholdDate.month, thresholdDate.day))) {
              await entity.delete();
              debugPrint('LogService: Deleted expired log file ${entity.path}');
            }
          } catch (_) {
            // Abaikan jika format file tidak cocok
          }
        }
      }
    } catch (e) {
      debugPrint('LogService cleanOldLogs error: $e');
    }
  }

  /// Mendapatkan daftar tanggal yang memiliki catatan log (dalam 30 hari terakhir)
  Future<List<DateTime>> getAvailableLogDates() async {
    try {
      if (!_isInitialized || _logDirectory == null) {
        await init();
      }

      if (_logDirectory == null || !await _logDirectory!.exists()) {
        return [];
      }

      final files = _logDirectory!.listSync();
      final List<DateTime> dates = [];

      for (final entity in files) {
        if (entity is File && p.basename(entity.path).startsWith(_logFilePrefix)) {
          final fileName = p.basenameWithoutExtension(entity.path);
          final datePart = fileName.replaceFirst(_logFilePrefix, '');
          try {
            final fileDate = _fileDateFormat.parse(datePart);
            dates.add(fileDate);
          } catch (_) {}
        }
      }

      // Urutkan dari yang terbaru ke terlama
      dates.sort((a, b) => b.compareTo(a));
      return dates;
    } catch (e) {
      debugPrint('LogService getAvailableLogDates error: $e');
      return [];
    }
  }

  /// Membaca isi log pada tanggal tertentu
  Future<String?> readLogContent(DateTime date) async {
    try {
      final file = getFileForDate(date);
      if (file != null && await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('LogService readLogContent error: $e');
      return null;
    }
  }

  /// Menyimpan file log langsung ke direktori Download / Penyimpanan lokal perangkat
  Future<String?> saveLogToDownloads(DateTime date) async {
    try {
      final sourceFile = getFileForDate(date);
      if (sourceFile == null || !await sourceFile.exists()) {
        return null;
      }

      final dateStr = _fileDateFormat.format(date);
      final fileName = 'cybeat_log_$dateStr.txt';

      Directory? targetDir;

      if (Platform.isAndroid) {
        // Coba akses folder Download publik Android (/storage/emulated/0/Download)
        final publicDownloadDir = Directory('/storage/emulated/0/Download');
        if (await publicDownloadDir.exists()) {
          targetDir = publicDownloadDir;
        } else {
          // Fallback ke downloads/external directory dari path_provider
          targetDir = await getDownloadsDirectory() ?? await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        targetDir = await getApplicationDocumentsDirectory();
      } else {
        targetDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (targetDir == null) {
        return null;
      }

      final destinationPath = p.join(targetDir.path, fileName);
      final destFile = File(destinationPath);
      await sourceFile.copy(destFile.path);

      return destinationPath;
    } catch (e) {
      debugPrint('LogService saveLogToDownloads error: $e');
      return null;
    }
  }

  /// Export / Share file log untuk tanggal tertentu
  Future<bool> shareLogFile(DateTime date, {Rect? sharePositionOrigin}) async {
    try {
      final file = getFileForDate(date);
      if (file == null || !await file.exists()) {
        return false;
      }

      final dateStr = _fileDateFormat.format(date);
      final xFile = XFile(
        file.path,
        mimeType: 'text/plain',
        name: 'cybeat_log_$dateStr.txt',
      );

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          sharePositionOrigin: sharePositionOrigin,
        ),
      );

      return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('LogService shareLogFile error: $e');
      return false;
    }
  }

  /// Mendapatkan ukuran file log dalam format yang mudah dibaca (KB / MB)
  Future<String> getLogFileSize(DateTime date) async {
    try {
      final file = getFileForDate(date);
      if (file != null && await file.exists()) {
        final bytes = await file.length();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
      return '0 B';
    } catch (_) {
      return '0 B';
    }
  }

  /// Menghapus semua file log (jika diperlukan)
  Future<void> clearAllLogs() async {
    try {
      if (_logDirectory != null && await _logDirectory!.exists()) {
        final files = _logDirectory!.listSync();
        for (final entity in files) {
          if (entity is File && p.basename(entity.path).startsWith(_logFilePrefix)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('LogService clearAllLogs error: $e');
    }
  }
}
