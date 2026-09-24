import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

class LogFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedLevelFilter;
  final bool isNewestFirst;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onLevelFilterChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleSortOrder;

  const LogFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedLevelFilter,
    required this.isNewestFirst,
    required this.onSearchChanged,
    required this.onLevelFilterChanged,
    required this.onClearSearch,
    required this.onToggleSortOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: SizedBox(
              height: 38.h,
              child: TextField(
                controller: searchController,
                style: TextStyle(fontSize: 12.sp),
                decoration: InputDecoration(
                  hintText: 'Cari dalam log...',
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18.sp,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 16.sp),
                          onPressed: onClearSearch,
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Level Dropdown Filter
          Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLevelFilter,
                icon: const Icon(Icons.filter_list_rounded, size: 18),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: HexColor('#1e0b2b'),
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Semua')),
                  DropdownMenuItem(value: 'ERROR', child: Text('Error')),
                  DropdownMenuItem(value: 'WARN', child: Text('Warning')),
                  DropdownMenuItem(value: 'INFO', child: Text('Info')),
                  DropdownMenuItem(value: 'SUCCESS', child: Text('Success')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    onLevelFilterChanged(val);
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Sort Order Toggle Button
          Tooltip(
            message: isNewestFirst ? 'Urutan: Terbaru ke Terlama' : 'Urutan: Terlama ke Terbaru',
            child: InkWell(
              onTap: onToggleSortOrder,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                height: 38.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: isNewestFirst ? HexColor('#8238be').withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isNewestFirst ? HexColor('#8238be').withValues(alpha: 0.3) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNewestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 16.sp,
                      color: isNewestFirst ? HexColor('#8238be') : HexColor('#1e0b2b'),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isNewestFirst ? 'Terbaru' : 'Terlama',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isNewestFirst ? HexColor('#8238be') : HexColor('#1e0b2b'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
