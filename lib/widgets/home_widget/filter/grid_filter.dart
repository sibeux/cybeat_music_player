import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

final _filterKey = GlobalKey();
final _filterAlbumController = Get.find<FilterAlbumController>();

class GridFilter extends StatelessWidget {
  const GridFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final generatedFilter = _getGeneratedFilter();
    return ReorderableBuilder(
      onReorder: (p0) {},
      enableDraggable: false,
      children: generatedFilter,
      builder: (context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            key: _filterKey,
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
    return List<Widget>.generate(
      _filterAlbumController.generateFilter.length,
      (index) => _getFilter(index: index),
    );
  }

  Widget _getFilter({required int index}) {
    final children = _filterAlbumController.children;
    final generatedFilter = _filterAlbumController.generateFilter;

    return CustomDraggable(
      key: Key(children[index].toString()),
      data: index,
      child: generatedFilter[index],
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
    return Obx(
      () => Container(
        alignment: Alignment.center,
        width: 80,
        height: 35,
        decoration: BoxDecoration(
          color: _filterAlbumController.getSelectedFilter.toString() ==
                  text.toLowerCase()
              ? HexColor('#ac8bc9')
              : _filterAlbumController.getSelectedFilter.toString() == ''
                  ? Colors.grey
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: _filterAlbumController.getSelectedFilter.toString() ==
                    text.toLowerCase()
                ? HexColor('#fefffe')
                : _filterAlbumController.getSelectedFilter.toString() == ''
                    ? HexColor('#fefffe')
                    : Colors.transparent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
