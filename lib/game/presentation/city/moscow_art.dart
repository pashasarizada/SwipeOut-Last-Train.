import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'city_art.dart';
import 'city_theme.dart';

/// Moscow: Khokhloma-style curls and berries, onion domes, a stepped
/// high-rise with a spire, snow. The final city: its stamp is gold.
final class MoscowArt extends CityArtBase {
  const MoscowArt();

  @override
  AmbientEffect get ambient => AmbientEffect.snow;

  @override
  void paintPattern(Canvas canvas, Size size, CityTheme theme) {
    final p = CityArtBase.patternPaint(theme);
    final berry = Paint()..color = theme.accent.withValues(alpha: 0.08);
    CityArtBase.tile(canvas, size, 88, (c, i) {
      final curl = Path()
        ..moveTo(c.dx - 24, c.dy + 10)
        ..quadraticBezierTo(c.dx - 6, c.dy - 26, c.dx + 14, c.dy - 6)
        ..quadraticBezierTo(c.dx + 22, c.dy + 6, c.dx + 8, c.dy + 8);
      canvas.drawPath(curl, p);
      canvas.drawCircle(c.translate(16, 16), 4, berry);
      canvas.drawCircle(c.translate(24, 10), 3, berry);
    });
  }

  static Path _onion(double x, double base, double u, double h) => Path()
    ..moveTo(x - u * 0.55, base - h)
    ..cubicTo(
      x - u * 0.9,
      base - h - u * 0.9,
      x - u * 0.1,
      base - h - u * 1.1,
      x,
      base - h - u * 1.6,
    )
    ..cubicTo(
      x + u * 0.1,
      base - h - u * 1.1,
      x + u * 0.9,
      base - h - u * 0.9,
      x + u * 0.55,
      base - h,
    )
    ..close();

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
    // Cathedral: drums with onion domes.
    for (final (x, h) in [(0.10, 2.2), (0.20, 3.2), (0.30, 2.6), (0.40, 2.0)]) {
      final cx = size.width * x + dx;
      canvas.drawRect(
        Rect.fromLTWH(cx - u * 0.45, base - u * h, u * 0.9, u * h),
        ink,
      );
      canvas.drawPath(_onion(cx, base, u, u * h), ink);
    }
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.06 + dx,
        base - u * 1.3,
        size.width * 0.38,
        u * 1.3,
      ),
      ink,
    );
    // Stepped high-rise with a spire and star-less tip.
    final sx = size.width * 0.75 + dx;
    for (final (w, h) in [(3.0, 2.4), (2.0, 4.0), (1.2, 5.6), (0.6, 6.6)]) {
      canvas.drawRect(
        Rect.fromLTWH(sx - u * w / 2, base - u * h, u * w, u * h),
        ink,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(sx - u * 0.12, base - u * 6.6)
        ..lineTo(sx, base - u * 8.2)
        ..lineTo(sx + u * 0.12, base - u * 6.6)
        ..close(),
      ink,
    );
    CityArtBase.windows(
      canvas,
      Rect.fromLTWH(sx - u * 1.0, base - u * 3.9, u * 2.0, u * 1.6),
      theme,
      5,
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
    // Six-armed snow crystal.
    for (var k = 0; k < 6; k++) {
      final a = k * math.pi / 3;
      final tip = c + Offset.fromDirection(a, r * 0.6);
      canvas.drawLine(c, tip, ink);
      final mid = c + Offset.fromDirection(a, r * 0.38);
      canvas.drawLine(mid, mid + Offset.fromDirection(a + 0.6, r * 0.16), ink);
      canvas.drawLine(mid, mid + Offset.fromDirection(a - 0.6, r * 0.16), ink);
    }
    if (gold) {
      canvas.drawCircle(
        c,
        r * 0.94,
        Paint()
          ..color = CityArtBase.gold.withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
      );
    }
  }
}
