import 'package:flutter/material.dart';

import '../../domain/level_definition.dart';
import '../board/board_layout.dart';
import '../game/tutorial_guide.dart';
import '../kit/motion_settings.dart';
import '../theme/app_colors.dart';

/// A drawn hand that taps where the tutorial wants the next touch: a
/// switch on the board, the lever, or Undo. It sits over the platform and
/// never takes a touch itself.
final class TutorialHand extends StatefulWidget {
  const TutorialHand({
    super.key,
    required this.target,
    required this.level,
    required this.boardKey,
    required this.leverKey,
    required this.undoKey,
  });

  final GuideTarget target;
  final LevelDefinition level;
  final GlobalKey boardKey;
  final GlobalKey leverKey;
  final GlobalKey undoKey;

  static const Duration tap = Duration(milliseconds: 1100);

  /// Taps played after each new target before the hand rests.
  static const int taps = 6;

  @override
  State<TutorialHand> createState() => _TutorialHandState();
}

class _TutorialHandState extends State<TutorialHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: TutorialHand.tap,
  );
  Offset? _point;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void didUpdateWidget(TutorialHand old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) _restart();
  }

  void _restart() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
    if (MotionSettings.reducedOf(context)) {
      _tap.value = 0.5;
    } else {
      _tap.repeat(count: TutorialHand.taps);
    }
  }

  /// Finds the target on screen once layout is done.
  void _locate() {
    if (!mounted) return;
    final self = context.findRenderObject();
    if (self is! RenderBox || !self.hasSize) return;
    final point = switch (widget.target) {
      GuideNode(:final nodeId) => _nodePoint(nodeId),
      GuideLever() => _centreOf(widget.leverKey),
      GuideUndo() => _centreOf(widget.undoKey),
    };
    final local = point == null ? null : self.globalToLocal(point);
    if (local != _point) setState(() => _point = local);
  }

  Offset? _nodePoint(String nodeId) {
    final board = widget.boardKey.currentContext?.findRenderObject();
    final node = widget.level.nodes[nodeId];
    if (board is! RenderBox || node == null) return null;
    final layout = BoardLayout(size: board.size);
    return board.localToGlobal(layout.toScreen(node.position));
  }

  Offset? _centreOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-measure after every rebuild: the board may have resized.
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
    final point = _point;
    return IgnorePointer(
      child: point == null
          ? const SizedBox.expand()
          : CustomPaint(
              size: Size.infinite,
              painter: _HandPainter(point, _tap),
            ),
    );
  }
}

/// A finger whose tip presses on [point], with a ring that spreads on
/// each press.
final class _HandPainter extends CustomPainter {
  _HandPainter(this.point, this.tap) : super(repaint: tap);

  final Offset point;
  final Animation<double> tap;

  @override
  void paint(Canvas canvas, Size size) {
    final t = tap.value;
    // Press in during the first half, lift during the second.
    final press = t < 0.5 ? t * 2 : (1 - t) * 2;
    canvas.drawCircle(
      point,
      14 + 16 * t,
      Paint()
        ..color = AppColors.textPrimary.withValues(alpha: 0.5 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final tip = point + const Offset(6, 8) * (1 - press);
    canvas
      ..save()
      ..translate(tip.dx, tip.dy)
      ..rotate(-0.45);
    final outline = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final skin = Paint()..color = AppColors.textPrimary;
    final finger = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7, 0, 14, 34),
      const Radius.circular(7),
    );
    final palm = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-9, 24, 30, 30),
      const Radius.circular(10),
    );
    canvas
      ..drawRRect(palm, outline)
      ..drawRRect(palm, skin)
      ..drawRRect(finger, outline)
      ..drawRRect(finger, skin)
      ..restore();
  }

  @override
  bool shouldRepaint(_HandPainter old) => old.point != point;
}
