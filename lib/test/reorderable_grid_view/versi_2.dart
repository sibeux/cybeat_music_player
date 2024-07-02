import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

enum ReorderableType {
  gridView,
  gridViewCount,
  gridViewExtent,
  gridViewBuilder,
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xfffaa025),
          surface: const Color(0xff271f16),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _startCounter = 20;

  final lockedIndices = <int>[0, 4];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);

  final _gridViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (children.length > 2) {
                // Pastikan indeks 10 ada di dalam range
                final child10 = children[10]; // Simpan elemen dari indeks 10
                children.removeAt(10); // Hapus elemen dari indeks 10
                children.insert(
                    1, child10); // Sisipkan kembali elemen ke indeks 0
                setState(() {}); // Update tampilan
              }
            },
            icon: const Icon(Icons.swap_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: _getReorderableWidget(),
      ),
    );
  }

  Widget _getReorderableWidget() {
    final generatedChildren = _getGeneratedChildren();
    return ReorderableBuilder(
      onReorder: _handleReorder,
      children: generatedChildren,
      builder: (children) {
        return GridView(
          key: _gridViewKey,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          primary: false,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          children: children,
        );
      },
    );
  }

  List<Widget> _getGeneratedChildren() {
    return List<Widget>.generate(
      children.length,
      (index) => _getChild(index: index),
    );
  }

  Widget _getChild({required int index}) {
    return CustomDraggable(
      key: Key(children[index].toString()),
      data: index,
      child: Container(
        decoration: BoxDecoration(
          color: lockedIndices.contains(index)
              ? Theme.of(context).disabledColor
              : Theme.of(context).colorScheme.primary,
        ),
        height: 100.0,
        width: 100.0,
        child: Center(
          child: Text(
            '${children[index]}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _handleReorder(ReorderedListFunction reorderedListFunction) {}
}
