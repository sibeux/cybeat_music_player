import 'package:cybeat_music_player/features/home/controllers/home_sort_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> showSortModalBottom(BuildContext context) {
  return showMaterialModalBottomSheet(
    context: context,
    // Pakai {useRootNavigator: true} agar modal bottom sheet tidak terhalangi-
    // oleh FloatingPlayingMusic dari root_page.dart
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      color: Colors.white,
      child: Column(
        // mainAxisSize: MainAxisSize.min - mencegah layar full
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.h, bottom: 10.h),
            height: 5.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Sort by',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Divider(
            height: 1.h,
            thickness: 1.h,
          ),
          // const SizedBox(height: 20),
          // by default, ListTile has a padding of 16
          const Column(
            children: [
              ListTileBottomModal(
                title: 'Recents',
              ),
              ListTileBottomModal(
                title: 'Alphabetical',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ListTileBottomModal extends StatelessWidget {
  const ListTileBottomModal({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final sortPreferencesController = Get.put(HomeSortPreferencesController());
    final sortValue = title == 'Recents' ? 'uid' : 'title';
    return Obx(() => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
          minVerticalPadding: 5.h,
          trailing: sortPreferencesController.sortValue == sortValue
              ? Icon(Icons.check, color: HexColor('#ac8bc9'))
              : null,
          title: Text(title),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          onTap: () {
            sortPreferencesController.saveSortBy(title);
            Get.back();
          },
        ));
  }
}
