part of 'forecast_painter.dart';

/// The forecast's marks: arrows, the waiting badge, goal glow, the cross.
extension _ForecastMarks on ForecastPainter {
  /// A soft 0–1 beat from the idle loop.
  double get _beat => 0.5 + 0.5 * math.sin(_flow.value * 2 * math.pi);

  void _paintGlow(Canvas canvas, TrainDef train) {
    final color = colorForStyle(train.style);
    canvas.drawCircle(
      _at(train.goalNode),
      26 + 3 * _beat,
      Paint()
        ..color = color.withValues(alpha: 0.35 + 0.25 * _beat)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  /// A red disc with a cross: shape as well as colour, for colour-blind
  /// players.
  void _paintCross(Canvas canvas, Offset c) {
    final r = 11 + 1.5 * _beat;
    canvas
      ..drawCircle(
        c,
        r + 6,
        Paint()..color = AppColors.danger.withValues(alpha: 0.25),
      )
      ..drawCircle(c, r, Paint()..color = AppColors.danger);
    GameIcon.paint(
      canvas,
      GameIconKind.cross,
      Rect.fromCircle(center: c, radius: r * 0.6),
      AppColors.textPrimary,
    );
  }

  void _paintArrow(Canvas canvas, TrainMove move) {
    final rail = _railOf(move);
    final from = rail.length * ForecastPainter.arrowFrom;
    final to = rail.length * ForecastPainter.arrowTo;
    if (to - from < 1) return;
    final color = colorFor(move);
    const head = 11.0;
    final neckAt = math.max(from, to - head);
    final end = rail.pointAt(to);
    final neck = rail.pointAt(neckAt);
    // The head's base is square to the rail where it sits, so a head on
    // a knee does not twist.
    final heading = rail.headingAt(neckAt);
    final normal = Offset(-math.sin(heading), math.cos(heading));
    final shaft = rail.segment(from, neckAt);

    final width = ForecastPainter.shaftWidth(high: highContrast);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    if (highContrast) {
      canvas.drawPath(shaft, stroke(AppColors.background, width + 4));
    }
    canvas.drawPath(
      shaft,
      stroke(color.withValues(alpha: highContrast ? 1 : 0.75), width),
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
      canvas.drawCircle(rail.pointAt(from + (neckAt - from) * t), 1.8, dot);
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
}
