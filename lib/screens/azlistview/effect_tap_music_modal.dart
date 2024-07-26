import 'package:flutter/material.dart';

double colorOnTap = 0;

class EffectTapMusicModal extends StatefulWidget {
  const EffectTapMusicModal({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  EffectTapMusicModalState createState() => EffectTapMusicModalState();
}

class EffectTapMusicModalState extends State<EffectTapMusicModal>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  // ignore: unused_field
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
      upperBound: 0.1,
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

    colorOnTap = 0.2;
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
    colorOnTap = 0;
  }

  @override
  Widget build(BuildContext context) {
    onTap() {
      // print('tapped');
    }

    DateTime dateTime1 = DateTime.now();

    return GestureDetector(
      onPanDown: (details) {
        _shrinkButtonSize();
      },
      onPanCancel: () {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onPanEnd: (_) {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onTapUp: (_) {
        // sejauh ini nggak ada gunanya
        _restoreButtonSize();
        Duration difference = DateTime.now().difference(dateTime1);
        if (difference.inMilliseconds < 500) {
          Future.delayed(
            const Duration(milliseconds: clickAnimationDurationMillis * 2),
            () => onTap.call(),
          );
        }
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: SizedBox(
          child: AnimatedContainer(
        width: double.infinity,
        color: Colors.grey.withOpacity(colorOnTap),
        duration: const Duration(milliseconds: 150),
        curve: Curves.fastOutSlowIn,
        child: widget.child,
      )),
    );
  }
}
