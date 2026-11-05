import 'package:flutter/material.dart';

import 'motion_settings.dart';

/// Departure-board text: when it appears or changes, each character flips
/// into place one after another (120 ms per flip, 40 ms stagger).
final class SplitFlapText extends StatefulWidget {
  const SplitFlapText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  static const Duration flip = Duration(milliseconds: 120);
  static const Duration stagger = Duration(milliseconds: 40);

  @override
  State<SplitFlapText> createState() => _SplitFlapTextState();
}

class _SplitFlapTextState extends State<SplitFlapText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  String _from = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.status == AnimationStatus.dismissed) _start('');
  }

  @override
  void didUpdateWidget(SplitFlapText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _start(old.text);
  }

  void _start(String from) {
    _from = from;
    if (MotionSettings.reducedOf(context)) {
      _controller.value = 1;
      return;
    }
    final length = widget.text.length;
    _controller.duration =
        SplitFlapText.flip +
        SplitFlapText.stagger * (length > 0 ? length - 1 : 0);
    _controller.forward(from: 0);
  }

  /// Long board lines shrink instead of overflowing narrow screens.
  static Widget _fit(Widget child) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: AlignmentDirectional.centerStart,
    child: child,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.value >= 1) {
          return _fit(Text(widget.text, style: widget.style, maxLines: 1));
        }
        final total = _controller.duration?.inMicroseconds ?? 1;
        final elapsed = _controller.value * total;
        final chars = <Widget>[];
        for (var i = 0; i < widget.text.length; i++) {
          final start = SplitFlapText.stagger.inMicroseconds * i;
          final t = ((elapsed - start) / SplitFlapText.flip.inMicroseconds)
              .clamp(0.0, 1.0);
          final shown = t < 0.5
              ? (i < _from.length ? _from[i] : ' ')
              : widget.text[i];
          chars.add(
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1, (1 - 2 * t).abs(), 1),
              child: Text(shown, style: widget.style),
            ),
          );
        }
        return _fit(Row(mainAxisSize: MainAxisSize.min, children: chars));
      },
    );
  }
}
