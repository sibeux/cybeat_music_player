import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class SpectrumAnimation extends StatefulWidget {
  final int barCount;

  const SpectrumAnimation({super.key, this.barCount = 10});

  @override
  State<SpectrumAnimation> createState() => _SpectrumAnimationState();
}

class _SpectrumAnimationState extends State<SpectrumAnimation>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.barCount; i++) {
      final controller = AnimationController(
        // semakin besar angka semakin lama naik turunnya.
        duration: Duration(milliseconds: 200 + Random().nextInt(500)),
        vsync: this,
      );

      final animation = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );

      controller.repeat(reverse: true);

      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: AnimatedBuilder(
        animation: Listenable.merge(_controllers),
        builder: (_, __) {
          return CustomPaint(
            painter: _SpectrumPainter(_animations.map((a) => a.value).toList()),
          );
        },
      ),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  final List<double> heights;

  _SpectrumPainter(this.heights);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HexColor('#8238be')
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / (heights.length * 2);

    final barWidth = size.width / (heights.length * 1.5);
    final spacing = barWidth / 2;
    final maxHeight = size.height;

    for (int i = 0; i < heights.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final barHeight = heights[i] * maxHeight;
      canvas.drawLine(
        Offset(x, maxHeight),
        Offset(x, maxHeight - barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
