import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/painting.dart';

import 'city_art.dart';
import 'city_theme.dart';

/// Baku: buta motif, flame-shaped towers, the Maiden Tower, Caspian waves.
final class BakuArt extends CityArtBase {
  const BakuArt();

  @override
  AmbientEffect get ambient => AmbientEffect.waves;

  static Path _buta(Offset c, double s, double angle) {
    final path = Path()
      ..moveTo(0, s)
      ..cubicTo(-s * 0.9, s * 0.6, -s * 0.7, -s * 0.6, 0, -s * 0.4)
      ..cubicTo(s * 0.5, -s * 0.9, s * 0.1, -s * 1.3, s * 0.45, -s * 1.1)
      ..cubicTo(s * 0.9, -s * 0.2, s * 0.7, s * 0.7, 0, s);
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    // Column-major 2D rotation + translation.
    final m = Float64List.fromList([
      cos, sin, 0, 0, //
      -sin, cos, 0, 0, //
      0, 0, 1, 0, //
      c.dx, c.dy, 0, 1, //
    ]);
    return path.transform(m);
  }

  @override
  void paintPattern(Canvas canvas, Size size, CityTheme theme) {
    final p = CityArtBase.patternPaint(theme);
    CityArtBase.tile(canvas, size, 80, (c, i) {
      canvas.drawPath(_buta(c, 18, i.isEven ? 0.4 : math.pi + 0.4), p);
    });
  }

  @override
  void paintSkyline(
    Canvas canvas,
    Size size,
    CityTheme theme, {
    double parallax = 0,
  }) {
    final u = CityArtBase.unit(size);
    final base = size.height;
    final dx = parallax * 2 * u;
    final ink = CityArtBase.silhouette(theme);
    // Three flame towers.
    for (final (i, h) in [(0, 5.6), (1, 6.4), (2, 5.0)].indexed) {
      final x = size.width * (0.55 + i * 0.12) + dx;
      final flame = Path()
        ..moveTo(x - u * 0.7, base)
        ..quadraticBezierTo(
          x - u * 0.9,
          base - u * h.$2 * 0.6,
          x,
          base - u * h.$2,
        )
        ..quadraticBezierTo(
          x + u * 0.8,
          base - u * h.$2 * 0.5,
          x + u * 0.7,
          base,
        )
        ..close();
      canvas.drawPath(flame, ink);
      canvas.drawPath(
        flame,
        Paint()
          ..color = theme.accent.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
    // Maiden Tower: a cylinder with its buttress.
    final mx = size.width * 0.18 + dx;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(mx, base - u * 3.4, u * 1.6, u * 3.4),
        topLeft: Radius.circular(u * 0.3),
        topRight: Radius.circular(u * 0.3),
      ),
      ink,
    );
    canvas.drawRect(
      Rect.fromLTWH(mx + u * 1.5, base - u * 2.2, u * 0.7, u * 2.2),
      ink,
    );
    // Old-city arches.
    for (var k = 0; k < 4; k++) {
      final ax = size.width * 0.02 + k * u * 0.9 + dx;
      canvas.drawRect(Rect.fromLTWH(ax, base - u * 1.1, u * 0.8, u * 1.1), ink);
    }
  }

  @override
  void paintStamp(
    Canvas canvas,
    Size size,
    CityTheme theme, {
    required bool gold,
  }) {
    final ink = CityArtBase.stampInk(theme, gold: gold);
    final r = size.shortestSide / 2;
    final c = size.center(Offset.zero);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: c, radius: r * 0.9),
        Radius.circular(r * 0.25),
      ),
      ink,
    );
    for (var k = 0; k < 4; k++) {
      final a = k * math.pi / 2 + math.pi / 4;
      canvas.drawPath(
        _buta(c + Offset.fromDirection(a, r * 0.42), r * 0.18, a),
        ink,
      );
    }
  }
}
