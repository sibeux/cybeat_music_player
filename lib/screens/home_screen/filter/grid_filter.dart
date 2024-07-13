import 'package:cybeat_music_player/screens/home_screen/filter/scale_tap_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:hexcolor/hexcolor.dart';

final _filterKey = GlobalKey();

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
      3,
      (index) => _getFilter(index: index),
    );
  }

  Widget _getFilter({required int index}) {
    final children = [0, 1, 2];
    final generatedFilter = [
      ScaleTapFilter(
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: HexColor('#ac8bc9'),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.cancel,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
      const ScaleTapFilter(child: FilterPlaylistAlbum(text: 'Playlist')),
      const ScaleTapFilter(child: FilterPlaylistAlbum(text: 'Album')),
    ];

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
    return Container(
      alignment: Alignment.center,
      width: 80,
      height: 35,
      decoration: BoxDecoration(
        // color: HexColor('#ac8bc9'),
        color: Colors.grey,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14,
            color: HexColor('#fefffe'),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
