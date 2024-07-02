import 'dart:async';

import 'package:cybeat_music_player/controller/sort_preferences_controller.dart';
import 'package:cybeat_music_player/widgets/home_screen/sort/show_sort_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
// import 'dart:developer' as developer;

double colorOnTap = 1;

class ScaleTapSort extends StatefulWidget {
  const ScaleTapSort({
    super.key,
  });

  @override
  ScaleTapSortState createState() => ScaleTapSortState();
}

class ScaleTapSortState extends State<ScaleTapSort>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  double _scaleTransformValue = 1;

  // needed for the "click" tap effect
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    animationController.forward();

    colorOnTap = 0.5;
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
    colorOnTap = 1;
  }

  final sortPreferencesController = Get.put(SortPreferencesController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        _shrinkButtonSize();
      },
      onPanCancel: () {
        _restoreButtonSize();
      },
      onPanEnd: (_) {
        _restoreButtonSize();
      },
      onTapUp: (_) {
        _restoreButtonSize();
        showSortModalBottom(context);
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: SizedBox(
          child: Opacity(
            opacity: colorOnTap,
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.arrow_up_arrow_down,
                  size: 20,
                ),
                const SizedBox(
                  width: 10,
                ),
                Obx(
                  () => Text(
                    sortPreferencesController.sortValue == 'uid'
                        ? "Recents"
                        : "Alphabetical",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
