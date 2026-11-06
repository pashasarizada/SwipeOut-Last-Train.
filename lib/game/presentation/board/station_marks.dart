part of 'network_painter.dart';

/// Signals (lamp head on a post) and goals (ring, symbol, check mark).
extension _StationMarks on NetworkPainter {
  void _paintSignal(Canvas canvas, Node node, Offset c) {
    final green = state.signals[node.id] == SignalAspect.green;
    final lit = green ? AppColors.signalGreen : AppColors.danger;
    final head = c + NetworkPainter.signalLampOffset;
    canvas.drawCircle(c, 8, Paint()..color = lit);
    canvas.drawLine(
      c,
      head,
      NetworkPainter._stroke(AppColors.trackInactive, 3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: head, width: 18, height: 26),
        const Radius.circular(7),
      ),
      Paint()..color = AppColors.background,
    );
    canvas.drawCircle(head + const Offset(0, -6), 5, Paint()..color = lit);
    canvas.drawCircle(
      head + const Offset(0, 6),
      4,
      NetworkPainter._stroke(AppColors.trackInactive, 1.5),
    );
    if (pending == ToggleSignal(node.id)) {
      canvas.drawCircle(
        c,
        18,
        NetworkPainter._stroke(AppColors.accentTurquoise, 3),
      );
    }
  }

  void _paintGoal(Canvas canvas, Node node, Offset c) {
    final owner = _ownerOf(node.id);
    final color = owner == null ? AppColors.track : colorForStyle(owner.style);
    canvas.drawCircle(c, 18, Paint()..color = AppColors.background);
    canvas.drawCircle(c, 18, NetworkPainter._stroke(color, 4));
    _label(canvas, c, owner?.symbol.glyph ?? '', color, 16);
    if (goalChecked(node.id)) {
      GameIcon.paint(
        canvas,
        GameIconKind.check,
        Rect.fromCircle(center: c + const Offset(16, -16), radius: 8),
        AppColors.signalGreen,
      );
    }
  }

  void _label(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: GameFonts.body,
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }
}
