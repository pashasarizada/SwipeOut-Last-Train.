import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Our own drawn icons — the game never shows Material Icons
/// (docs/UI_UX_GUIDELINES.md §1).
enum GameIconKind {
  gear,
  lock,
  star,
  starOutline,
  cross,
  route,
  signal,
  horn,
  check,
  bulb,
  info,
}

/// A small drawn icon, [size] pt square.
final class GameIcon extends StatelessWidget {
  const GameIcon(
    this.kind, {
    super.key,
    this.size = 20,
    required this.color,
    this.semanticLabel,
  });

  final GameIconKind kind;
  final double size;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _GameIconPainter(kind, color),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: icon)
        : Semantics(label: semanticLabel, image: true, child: icon);
  }

  /// Paints [kind] into [box]; shared with the board painter.
  static void paint(Canvas canvas, GameIconKind kind, Rect box, Color color) {
    final s = box.shortestSide;
    final o = box.center;
    Offset p(double x, double y) => o + Offset(x * s, y * s);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (kind) {
      case GameIconKind.gear:
        // A cog: eight teeth round a ring with a hole.
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            p(0.30 * math.cos(a), 0.30 * math.sin(a)),
            p(0.44 * math.cos(a), 0.44 * math.sin(a)),
            line..strokeWidth = s * 0.14,
          );
        }
        canvas.drawCircle(o, s * 0.28, line..strokeWidth = s * 0.12);
        canvas.drawCircle(o, s * 0.08, fill);
      case GameIconKind.lock:
        canvas.drawArc(
          Rect.fromCenter(
            center: p(0, -0.12),
            width: s * 0.44,
            height: s * 0.5,
          ),
          math.pi,
          math.pi,
          false,
          line,
        );
        canvas.drawLine(p(-0.22, -0.12), p(-0.22, 0.02), line);
        canvas.drawLine(p(0.22, -0.12), p(0.22, 0.02), line);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: p(0, 0.2),
              width: s * 0.66,
              height: s * 0.48,
            ),
            Radius.circular(s * 0.08),
          ),
          fill,
        );
      case GameIconKind.star || GameIconKind.starOutline:
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? 0.46 : 0.19;
          final a = -math.pi / 2 + i * math.pi / 5;
          final q = p(r * math.cos(a), r * math.sin(a));
          i == 0 ? star.moveTo(q.dx, q.dy) : star.lineTo(q.dx, q.dy);
        }
        star.close();
        canvas.drawPath(
          star,
          kind == GameIconKind.star ? fill : (line..strokeWidth = s * 0.08),
        );
      case GameIconKind.cross:
        canvas.drawLine(p(-0.28, -0.28), p(0.28, 0.28), line);
        canvas.drawLine(p(0.28, -0.28), p(-0.28, 0.28), line);
      case GameIconKind.route:
        // A switch: one trunk splitting into two branches.
        canvas.drawLine(p(0, 0.4), p(0, 0.02), line);
        canvas.drawLine(p(0, 0.02), p(-0.3, -0.34), line);
        canvas.drawLine(p(0, 0.02), p(0.3, -0.34), line);
        canvas.drawCircle(p(0, 0.02), s * 0.1, fill);
      case GameIconKind.signal:
        // A signal head on its post: two lamps, the top one lit.
        canvas.drawLine(p(0, 0.18), p(0, 0.46), line);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: p(0, -0.12),
              width: s * 0.42,
              height: s * 0.66,
            ),
            Radius.circular(s * 0.14),
          ),
          line..strokeWidth = s * 0.09,
        );
        canvas.drawCircle(p(0, -0.27), s * 0.1, fill);
        canvas.drawCircle(p(0, 0.03), s * 0.08, line);
      case GameIconKind.horn:
        // A station loudspeaker with two sound waves.
        final cone = Path()
          ..moveTo(p(-0.42, -0.12).dx, p(-0.42, -0.12).dy)
          ..lineTo(p(-0.18, -0.12).dx, p(-0.18, -0.12).dy)
          ..lineTo(p(0.06, -0.34).dx, p(0.06, -0.34).dy)
          ..lineTo(p(0.06, 0.34).dx, p(0.06, 0.34).dy)
          ..lineTo(p(-0.18, 0.12).dx, p(-0.18, 0.12).dy)
          ..lineTo(p(-0.42, 0.12).dx, p(-0.42, 0.12).dy)
          ..close();
        canvas.drawPath(cone, fill);
        for (final r in [0.2, 0.36]) {
          canvas.drawArc(
            Rect.fromCircle(center: p(0.08, 0), radius: r * s),
            -math.pi / 4,
            math.pi / 2,
            false,
            line,
          );
        }
      case GameIconKind.check:
        canvas.drawPath(
          Path()
            ..moveTo(p(-0.32, 0.02).dx, p(-0.32, 0.02).dy)
            ..lineTo(p(-0.1, 0.26).dx, p(-0.1, 0.26).dy)
            ..lineTo(p(0.34, -0.26).dx, p(0.34, -0.26).dy),
          line,
        );
      case GameIconKind.info:
        // A ringed "i": there is more to read here.
        canvas
          ..drawCircle(o, s * 0.4, line..strokeWidth = s * 0.1)
          ..drawCircle(p(0, -0.18), s * 0.065, fill)
          ..drawLine(p(0, -0.04), p(0, 0.22), line..strokeWidth = s * 0.12);
      case GameIconKind.bulb:
        // A light bulb: glass, a waist, two base rings.
        canvas
          ..drawCircle(p(0, -0.1), s * 0.26, line)
          ..drawLine(p(-0.1, 0.17), p(0.1, 0.17), line)
          ..drawLine(p(-0.08, 0.3), p(0.08, 0.3), line)
          ..drawCircle(p(0, -0.1), s * 0.07, fill);
    }
  }
}

final class _GameIconPainter extends CustomPainter {
  const _GameIconPainter(this.kind, this.color);

  final GameIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) =>
      GameIcon.paint(canvas, kind, Offset.zero & size, color);

  @override
  bool shouldRepaint(_GameIconPainter old) =>
      old.kind != kind || old.color != color;
}
