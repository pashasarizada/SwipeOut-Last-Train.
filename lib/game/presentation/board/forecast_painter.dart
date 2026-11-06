import 'package:flutter/widgets.dart';

import '../../domain/level_definition.dart';
import '../../domain/pulse_forecast.dart';
import '../theme/app_colors.dart';
import 'board_layout.dart';

/// What a train shows for the next pulse.
enum ForecastMark { arrow, waiting }

/// The next pulse, drawn without words (docs/GAME_DESIGN_V2.md §3.2/5 —
/// one pulse ahead, never the solution): an arrow in the train's colour
/// towards the node each moving train will enter, and a "waiting" badge
/// beside each train that stays. [flow] (0–1, looping) runs dots along the
/// arrows.
final class ForecastPainter extends CustomPainter {
  ForecastPainter({
    required this.level,
    required this.forecast,
    required this.layout,
    Animation<double> flow = kAlwaysDismissedAnimation,
  }) : _flow = flow,
       super(repaint: flow);

  final LevelDefinition level;

  /// Null while a pulse plays or once the run is over: nothing is drawn.
  final PulseForecast? forecast;
  final BoardLayout layout;
  final Animation<double> _flow;

  /// Where along its edge an arrow starts and ends.
  static const double arrowFrom = 0.30;
  static const double arrowTo = 0.85;

  /// Offset of the waiting badge from the train's node.
  static const Offset badgeOffset = Offset(20, -20);

  static ForecastMark markOf(TrainMove move) =>
      move.moves ? ForecastMark.arrow : ForecastMark.waiting;

  Offset _at(String nodeId) => layout.toScreen(level.nodes[nodeId]!.position);

  /// The arrow's screen ends for a moving train.
  (Offset, Offset) arrowFor(TrainMove move) {
    final from = _at(move.from);
    final delta = _at(move.to!) - from;
    return (from + delta * arrowFrom, from + delta * arrowTo);
  }

  /// The colour [move] is drawn in.
  Color colorFor(TrainMove move) =>
      colorForStyle(level.trainDef(move.trainId)!.style);

  @override
  void paint(Canvas canvas, Size size) {
    final f = forecast;
    if (f == null) return;
    for (final move in f.moves) {
      switch (markOf(move)) {
        case ForecastMark.arrow:
          _paintArrow(canvas, move);
        case ForecastMark.waiting:
          _paintWaiting(canvas, _at(move.from) + badgeOffset);
      }
    }
  }

  void _paintArrow(Canvas canvas, TrainMove move) {
    final (start, end) = arrowFor(move);
    final color = colorFor(move);
    final direction = end - start;
    if (direction.distance < 1) return;
    final unit = direction / direction.distance;
    final normal = Offset(-unit.dy, unit.dx);
    const head = 11.0;
    final neck = end - unit * head;

    canvas.drawLine(
      start,
      neck,
      Paint()
        ..color = color.withValues(alpha: 0.75)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(neck.dx + normal.dx * 8, neck.dy + normal.dy * 8)
        ..lineTo(neck.dx - normal.dx * 8, neck.dy - normal.dy * 8)
        ..close(),
      Paint()..color = color,
    );
    // Dots run along the shaft so the arrow reads as motion.
    final dot = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.85);
    for (var i = 0; i < 2; i++) {
      final t = (_flow.value + i / 2) % 1;
      canvas.drawCircle(Offset.lerp(start, neck, t)!, 1.8, dot);
    }
  }

  void _paintWaiting(Canvas canvas, Offset c) {
    canvas
      ..drawCircle(c, 9, Paint()..color = AppColors.surface)
      ..drawCircle(
        c,
        9,
        Paint()
          ..color = AppColors.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    final bar = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (final dx in [-2.6, 2.6]) {
      canvas.drawLine(c + Offset(dx, -3.6), c + Offset(dx, 3.6), bar);
    }
  }

  @override
  bool shouldRepaint(ForecastPainter old) =>
      old.forecast != forecast || old.layout != layout || old.level != level;
}
