import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:cybeat_music_player/features/setting_app/widgets/log_viewer/log_action_bar.dart';
import 'package:cybeat_music_player/features/setting_app/widgets/log_viewer/log_content_viewer.dart';
import 'package:cybeat_music_player/features/setting_app/widgets/log_viewer/log_date_selector.dart';
import 'package:cybeat_music_player/features/setting_app/widgets/log_viewer/log_filter_bar.dart';
import 'package:cybeat_music_player/features/setting_app/widgets/log_viewer/log_viewer_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LogViewerModal extends StatefulWidget {
  const LogViewerModal({super.key});

  @override
  State<LogViewerModal> createState() => _LogViewerModalState();
}

class _LogViewerModalState extends State<LogViewerModal> {
  final SettingAppController controller = Get.find<SettingAppController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLevelFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAvailableLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.88.sh,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header (Drag handle + Title + Close button)
          const LogViewerHeader(),

          // Date selection & available date chips
          LogDateSelector(controller: controller),

          // Action buttons (Download/Share & Copy)
          LogActionBar(controller: controller),

          SizedBox(height: 6.h),

          // Filter bar (Search input & Level dropdown)
          LogFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedLevelFilter: _selectedLevelFilter,
            onSearchChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            onLevelFilterChanged: (val) {
              setState(() {
                _selectedLevelFilter = val;
              });
            },
            onClearSearch: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          ),

          SizedBox(height: 10.h),

          // Log terminal content viewer
          LogContentViewer(
            controller: controller,
            searchQuery: _searchQuery,
            selectedLevelFilter: _selectedLevelFilter,
          ),
        ],
      ),
    );
  }
}
