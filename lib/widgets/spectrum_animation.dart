import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SpectrumAnimation extends StatefulWidget {
  const SpectrumAnimation({super.key});

  @override
  State<SpectrumAnimation> createState() => _SpectrumAnimationState();
}

class _SpectrumAnimationState extends State<SpectrumAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/music-spectrum.json',
      controller: _controller,
      onLoaded: (composition) {
        // Configure the AnimationController with the duration of the
        // Lottie file and start the animation.
        _controller
          ..duration = composition.duration
          ..forward();
      },
    );
  }
}
