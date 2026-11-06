part of 'network_painter.dart';

/// Metro stops (ticks, depot ends, buffers), signals (lamp head on a
/// post), goals (ring, symbol, check mark) and the goals' station names.
extension _StationMarks on NetworkPainter {
  /// The colour of the line serving [node]; white in High Contrast.
  Color _lineColourAt(Node node) {
    if (highContrast) return AppColors.textPrimary;
    final edges = level.edgesOf(node.id);
    if (edges.isEmpty) return AppColors.track;
    return theme.lines[map.lines.colorOf(edges.first.id)];
  }

  /// A short bar across the line: a stop, or the buffer of a dead end.
  void _paintTick(
    Canvas canvas,
    Node node,
    Offset c, {
    required double half,
    required double width,
  }) {
    final edges = level.edgesOf(node.id);
    if (edges.isEmpty) return;
    final h = map.geometry.from(node.id, edges.first.id).headingAt(0);
    final across = Offset(-math.sin(h), math.cos(h)) * half;
    canvas.drawLine(
      c - across,
      c + across,
      NetworkPainter._stroke(_lineColourAt(node), width)
        ..strokeCap = StrokeCap.butt,
    );
  }

  /// A depot: an end box outlined in the line's colour, light enough to
  /// leave a waiting train the main thing seen.
  void _paintDepot(Canvas canvas, Node node, Offset c) {
    final block = RRect.fromRectAndRadius(
      Rect.fromCircle(center: c, radius: 15),
      const Radius.circular(6),
    );
    canvas
      ..drawRRect(block, Paint()..color = theme.background)
      ..drawRRect(block, NetworkPainter._stroke(_lineColourAt(node), 3));
  }

  /// Station names beside the goals, on a dark plate so they read over
  /// the city pattern.
  void _paintNames(Canvas canvas) {
    for (final MapEntry(key: id, value: box) in map.labels.placed.entries) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(4)),
        Paint()
          ..color = theme.background.withValues(alpha: highContrast ? 1 : 0.7),
      );
      final painter = TextPainter(
        text: TextSpan(
          text: level.nodes[id]!.label,
          style: StationLabels.style.copyWith(
            color: AppColors.textPrimary.withValues(
              alpha: highContrast ? 1 : 0.85,
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter
        ..paint(
          canvas,
          box.center - Offset(painter.width / 2, painter.height / 2),
        )
        ..dispose();
    }
  }

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
