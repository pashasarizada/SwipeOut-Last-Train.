import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'city_art.dart';
import 'city_theme.dart';

/// London: brick bond, a clock tower, bridge towers, terraced roofs, rain.
/// (No roundel, no official lettering.)
final class LondonArt extends CityArtBase {
  const LondonArt();

  @override
  AmbientEffect get ambient => AmbientEffect.rain;

  @override
  void paintPattern(Canvas canvas, Size size, CityTheme theme) {
    final p = CityArtBase.patternPaint(theme);
    const w = 44.0;
    const h = 18.0;
    for (var row = 0; row * h < size.height; row++) {
      final shift = row.isEven ? 0.0 : w / 2;
      for (var x = -w + shift; x < size.width; x += w) {
        canvas.drawRect(Rect.fromLTWH(x, row * h, w, h), p);
      }
    }
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
    // Terraced houses with chimneys.
    for (var k = 0; k < 5; k++) {
      final x = k * u * 1.3 + dx;
      canvas.drawRect(Rect.fromLTWH(x, base - u * 1.8, u * 1.25, u * 1.8), ink);
      canvas.drawRect(
        Rect.fromLTWH(x + u * 0.8, base - u * 2.3, u * 0.2, u * 0.5),
        ink,
      );
    }
    // Clock tower.
    final cx = size.width * 0.62 + dx;
    canvas.drawRect(
      Rect.fromLTWH(cx - u * 0.55, base - u * 5.5, u * 1.1, u * 5.5),
      ink,
    );
    final roof = Path()
      ..moveTo(cx - u * 0.65, base - u * 5.5)
      ..lineTo(cx, base - u * 7.2)
      ..lineTo(cx + u * 0.65, base - u * 5.5)
      ..close();
    canvas.drawPath(roof, ink);
    final face = Offset(cx, base - u * 4.8);
    canvas.drawCircle(
      face,
      u * 0.38,
      Paint()..color = theme.accent.withValues(alpha: 0.75),
    );
    final hand = Paint()
      ..color = ink.color
      ..strokeWidth = 1.5;
    canvas.drawLine(
      face,
      face + Offset.fromDirection(-math.pi / 2, u * 0.28),
      hand,
    );
    canvas.drawLine(
      face,
      face + Offset.fromDirection(-math.pi / 6, u * 0.2),
      hand,
    );
    // Bridge towers with a span.
    for (final bx in [0.80, 0.95]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * bx + dx, base - u * 3.4, u * 0.7, u * 3.4),
        ink,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.80 + dx,
        base - u * 2.6,
        size.width * 0.15,
        u * 0.25,
      ),
      ink,
    );
  }

  @override
  void paintStamp(
    Canvas canvas,
    Size size,
    CityTheme theme, {
    required bool gold,
  }) {
    final ink = CityArtBase.stampInk(theme, gold: gold);
    CityArtBase.stampRings(canvas, size, ink);
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    for (var k = 0; k < 12; k++) {
      final a = k * math.pi / 6;
      canvas.drawLine(
        c + Offset.fromDirection(a, r * 0.5),
        c + Offset.fromDirection(a, r * 0.62),
        ink,
      );
    }
    canvas.drawLine(c, c + Offset.fromDirection(-math.pi / 2, r * 0.42), ink);
    canvas.drawLine(c, c + Offset.fromDirection(-math.pi / 8, r * 0.3), ink);
  }
}
