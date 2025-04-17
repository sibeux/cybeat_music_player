import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class GridFilter extends StatelessWidget {
  const GridFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey filterKey = GlobalKey(); // ⬅️ Dideklarasikan di sini
    final generatedFilter = _getGeneratedFilter();
    return ReorderableBuilder(
      onReorder: (p0) {},
      children: generatedFilter,
      builder: (context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            key: filterKey,
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: context,
          ),
        );
      },
    );
  }

  List<Widget> _getGeneratedFilter() {
    final filterAlbumController = Get.find<FilterAlbumController>();
    return List<Widget>.generate(
      filterAlbumController.generateFilter.length,
      (index) => _getFilter(index: index),
    );
  }

  Widget _getFilter({required int index}) {
    final filterAlbumController = Get.find<FilterAlbumController>();
    return CustomDraggable(
      key: Key(filterAlbumController.children[index].toString()),
      data: index,
      child: filterAlbumController.generateFilter[index],
    );
  }
}

class FilterPlaylistAlbum extends StatelessWidget {
  const FilterPlaylistAlbum({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final filterAlbumController = Get.find<FilterAlbumController>();
    return Obx(
      () => Container(
        alignment: Alignment.center,
        width: 80,
        height: 35,
        decoration: BoxDecoration(
          color: filterAlbumController.getSelectedFilter.toString() ==
                  text.toLowerCase()
              ? HexColor('#ac8bc9')
              : filterAlbumController.getSelectedFilter.toString() == ''
                  ? Colors.grey
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: filterAlbumController.getSelectedFilter.toString() ==
                    text.toLowerCase()
                ? HexColor('#fefffe')
                : filterAlbumController.getSelectedFilter.toString() == ''
                    ? HexColor('#fefffe')
                    : Colors.transparent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
