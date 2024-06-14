import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SpectrumAnimation extends StatefulWidget {
  const SpectrumAnimation({super.key});

  @override
  State<SpectrumAnimation> createState() => _SpectrumAnimationState();
}

class _SpectrumAnimationState extends State<SpectrumAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.network(
      'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/B.json',
      controller: _controller,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..repeat();
      },
    );
  }
}
