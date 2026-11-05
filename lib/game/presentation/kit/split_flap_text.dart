import 'package:flutter/material.dart';

import 'motion_settings.dart';

/// Departure-board text: when it appears or changes, each character that
/// changed flips into place one after another (120 ms per flip, 40 ms
/// stagger); characters that stay the same never move.
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

  /// Flip order of each changed character; unchanged ones are absent.
  Map<int, int> _slots = const {};

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
    final text = widget.text;
    var order = 0;
    _slots = {
      for (var i = 0; i < text.length; i++)
        if (i >= from.length || from[i] != text[i]) i: order++,
    };
    if (MotionSettings.reducedOf(context) || _slots.isEmpty) {
      _controller.value = 1;
      return;
    }
    _controller.duration =
        SplitFlapText.flip + SplitFlapText.stagger * (_slots.length - 1);
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
          final slot = _slots[i];
          final start = SplitFlapText.stagger.inMicroseconds * (slot ?? 0);
          final t = slot == null
              ? 1.0
              : ((elapsed - start) / SplitFlapText.flip.inMicroseconds).clamp(
                  0.0,
                  1.0,
                );
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
