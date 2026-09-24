import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LogContentViewer extends StatelessWidget {
  final SettingAppController controller;
  final String searchQuery;
  final String selectedLevelFilter;

  const LogContentViewer({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.selectedLevelFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Obx(() {
          if (controller.isLoadingLog.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          }

          final rawContent = controller.currentLogContent.value;
          if (rawContent.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    color: Colors.grey.shade600,
                    size: 40.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tidak ada catatan log pada tanggal ini',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter baris log berdasarkan level dan kata kunci pencarian
          final lines = rawContent.split('\n');
          final filteredLines = lines.where((line) {
            if (line.isEmpty) return false;
            if (selectedLevelFilter != 'ALL') {
              if (!_matchesLevel(line, selectedLevelFilter)) {
                return false;
              }
            }
            if (searchQuery.isNotEmpty) {
              return line.toLowerCase().contains(searchQuery.toLowerCase());
            }
            return true;
          }).toList();

          if (filteredLines.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada log yang cocok dengan filter',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12.sp,
                ),
              ),
            );
          }

          return Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: filteredLines.length,
              physics: const BouncingScrollPhysics(),
              addRepaintBoundaries: false,
              itemBuilder: (context, index) {
                final line = filteredLines[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: _buildLogLine(line),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  bool _matchesLevel(String line, String level) {
    if (line.contains('[$level]')) return true;
    if (level == 'ERROR') {
      if (line.toLowerCase().contains('failed host lookup') ||
          line.toLowerCase().contains('error') ||
          line.startsWith('  Exception') ||
          line.startsWith('  StackTrace')) {
        return true;
      }
    } else if (level == 'SUCCESS') {
      if (line.contains('SUCCESS')) return true;
    } else if (level == 'WARN') {
      if (line.startsWith('retry') || line.contains('[WARN]')) return true;
    } else if (level == 'INFO') {
      if (line.startsWith('AppLifecycleState') ||
          line.startsWith('Network') ||
          line.startsWith('User pressed') ||
          line.startsWith('GET ') ||
          line.startsWith('POST ') ||
          line.startsWith('DELETE ') ||
          line.contains('[INFO]')) {
        return true;
      }
    }
    return false;
  }

  Widget _buildLogLine(String line) {
    Color textColor = const Color(0xFFD4D4D4);
    FontWeight fontWeight = FontWeight.normal;

    // Check timestamp (HH:mm:ss)
    final isTimestamp = RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(line.trim());

    if (isTimestamp) {
      textColor = const Color(0xFF9E9E9E);
      fontWeight = FontWeight.w600;
    } else if (line.contains('SUCCESS') || line.contains('[SUCCESS]')) {
      textColor = const Color(0xFF06D6A0);
      fontWeight = FontWeight.bold;
    } else if (line.contains('Failed host lookup') ||
        line.contains('[ERROR]') ||
        line.toLowerCase().contains('error') ||
        line.contains('disconnected')) {
      textColor = const Color(0xFFFF6B6B);
      fontWeight = FontWeight.w600;
    } else if (line.startsWith('retry') || line.contains('[WARN]')) {
      textColor = const Color(0xFFFFD166);
      fontWeight = FontWeight.w600;
    } else if (line.startsWith('AppLifecycleState') ||
        line.startsWith('Network') ||
        line.startsWith('User pressed') ||
        line.startsWith('GET ') ||
        line.startsWith('POST ') ||
        line.startsWith('DELETE ') ||
        line.contains('[INFO]')) {
      textColor = const Color(0xFF80D8FF);
    } else if (line.startsWith('  Exception') ||
        line.startsWith('  StackTrace')) {
      textColor = const Color(0xFFFFA8A8);
    }

    return Text(
      line,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11.5.sp,
        color: textColor,
        fontWeight: fontWeight,
        height: 1.35,
      ),
    );
  }
}
