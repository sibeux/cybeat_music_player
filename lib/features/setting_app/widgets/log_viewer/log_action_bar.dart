import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class LogActionBar extends StatelessWidget {
  final SettingAppController controller;

  const LogActionBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Row(
        children: [
          // Download / Share Button
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#8238be'),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                final box = context.findRenderObject() as RenderBox?;
                final origin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                controller.downloadOrShareLog(sharePositionOrigin: origin);
              },
              icon: Icon(Icons.file_download_rounded, size: 20.sp),
              label: Obx(() {
                final size = controller.currentLogSize.value;
                return Text(
                  'Download Log ($size)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: 10.w),
          // Copy All Button
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: HexColor('#1e0b2b'),
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                final content = controller.currentLogContent.value;
                if (content.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Tidak ada teks log untuk disalin',
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                  );
                  return;
                }
                Clipboard.setData(ClipboardData(text: content));
                Fluttertoast.showToast(
                  msg: 'Log berhasil disalin ke clipboard',
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
              },
              icon: Icon(Icons.copy_rounded, size: 18.sp),
              label: Text(
                'Salin',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
