import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimatedRotateCover extends StatefulWidget {
  const AnimatedRotateCover({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<AnimatedRotateCover> createState() => _AnimatedRotateCoverState();
}

class _AnimatedRotateCoverState extends State<AnimatedRotateCover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      // semakin besar angka semakin lama putaran
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.141592653589793,
          child: child,
        );
      },
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  maxHeightDiskCache: 50,
                  maxWidthDiskCache: 50,
                  filterQuality: FilterQuality.low,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/placeholder_cover_music.png',
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder_cover_music.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
