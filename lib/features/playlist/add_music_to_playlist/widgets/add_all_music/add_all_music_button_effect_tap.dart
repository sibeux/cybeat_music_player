import 'package:flutter/cupertino.dart';

double colorOnTap = 1;

class AddAllMusicButtonEffectTap extends StatefulWidget {
  const AddAllMusicButtonEffectTap({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final Function()? onTap;

  @override
  AddAllMusicButtonEffectTapState createState() =>
      AddAllMusicButtonEffectTapState();
}

class AddAllMusicButtonEffectTapState
    extends State<AddAllMusicButtonEffectTap> {
  Widget get child => widget.child;
  static const clickAnimationDurationMillis = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _shrinkButtonSize() {
    setState(() {
      colorOnTap = 0.3;
    });
  }

  void _restoreButtonSize() {
    setState(() {
      colorOnTap = 1;
    });
  }

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
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: _restoreButtonSize,
      child: Opacity(
        opacity: colorOnTap,
        child: child,
      ),
    );
  }
}
