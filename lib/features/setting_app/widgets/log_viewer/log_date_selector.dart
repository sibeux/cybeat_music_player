import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class LogDateSelector extends StatelessWidget {
  final SettingAppController controller;

  const LogDateSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector Card
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: HexColor('#f8f7fb'),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: HexColor('#e8e5f0')),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: HexColor('#8238be'), size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() {
                    final date = controller.selectedDate.value;
                    final isToday = DateUtils.isSameDay(date, DateTime.now());
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Log:',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: HexColor('#676767'),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6.w,
                          runSpacing: 2.h,
                          children: [
                            Text(
                              DateFormat('EEE, dd MMM yyyy').format(date),
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: HexColor('#1e0b2b'),
                              ),
                            ),
                            if (isToday)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: HexColor('#8238be'),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'Hari ini',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: HexColor('#8238be'),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: HexColor('#8238be')),
                    ),
                  ),
                  onPressed: () => controller.pickLogDate(context),
                  icon: Icon(Icons.edit_calendar_rounded, size: 16.sp),
                  label: Text(
                    'Pilih',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Available Dates Horizontal Chips
        Obx(() {
          final dates = controller.availableLogDates;
          if (dates.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 8.h),
            child: SizedBox(
              height: 32.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final d = dates[index];
                  final isSelected =
                      DateUtils.isSameDay(d, controller.selectedDate.value);
                  return ActionChip(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    label: Text(
                      DateFormat('dd MMM').format(d),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : HexColor('#1e0b2b'),
                      ),
                    ),
                    backgroundColor:
                        isSelected ? HexColor('#8238be') : Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected
                          ? HexColor('#8238be')
                          : Colors.grey.shade300,
                    ),
                    onPressed: () => controller.selectDate(d),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
