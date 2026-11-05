import 'package:flutter/painting.dart';

import 'city_art.dart';
import 'city_theme.dart';

/// Paris: Art Nouveau whiplash curves, a daytime Eiffel outline (no night
/// light show), mansard roofs, the curve of the Seine.
final class ParisArt extends CityArtBase {
  const ParisArt();

  @override
  AmbientEffect get ambient => AmbientEffect.lamps;

  /// Curved legs, two platforms and a spire, standing on [foot].
  static Path _eiffel(Offset foot, double u, double h) {
    final x = foot.dx;
    final base = foot.dy;
    return Path()
      ..moveTo(x - u * 1.5, base)
      ..quadraticBezierTo(
        x - u * 0.5,
        base - h * 0.35,
        x - u * 0.18,
        base - h * 0.9,
      )
      ..lineTo(x, base - h)
      ..lineTo(x + u * 0.18, base - h * 0.9)
      ..quadraticBezierTo(x + u * 0.5, base - h * 0.35, x + u * 1.5, base)
      ..lineTo(x + u * 0.7, base)
      ..quadraticBezierTo(x, base - h * 0.2, x - u * 0.7, base)
      ..close()
      ..addRect(
        Rect.fromCenter(
          center: Offset(x, base - h * 0.32),
          width: u * 1.76,
          height: u * 0.14,
        ),
      )
      ..addRect(
        Rect.fromCenter(
          center: Offset(x, base - h * 0.58),
          width: u * 0.96,
          height: u * 0.14,
        ),
      );
  }

  @override
  void paintPattern(Canvas canvas, Size size, CityTheme theme) {
    final p = CityArtBase.patternPaint(theme);
    CityArtBase.tile(canvas, size, 90, (c, i) {
      final path = Path()
        ..moveTo(c.dx - 30, c.dy + 20)
        ..cubicTo(
          c.dx - 30,
          c.dy - 30,
          c.dx + 10,
          c.dy + 30,
          c.dx + 6,
          c.dy - 18,
        )
        ..cubicTo(
          c.dx + 4,
          c.dy - 30,
          c.dx + 26,
          c.dy - 26,
          c.dx + 22,
          c.dy - 10,
        );
      canvas.drawPath(path, p);
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
    // Mansard roofs.
    for (var k = 0; k < 6; k++) {
      final x = k * u * 1.6 - u * 0.5 + dx;
      final top = base - u * (1.6 + (k % 3) * 0.3);
      final roof = Path()
        ..moveTo(x, base)
        ..lineTo(x, top)
        ..lineTo(x + u * 0.25, top - u * 0.5)
        ..lineTo(x + u * 1.35, top - u * 0.5)
        ..lineTo(x + u * 1.6, top)
        ..lineTo(x + u * 1.6, base)
        ..close();
      canvas.drawPath(roof, ink);
      canvas.drawRect(
        Rect.fromLTWH(x + u * 1.1, top - u * 0.8, u * 0.15, u * 0.35),
        ink,
      );
    }
    // Eiffel outline (daytime, no light show).
    canvas.drawPath(
      _eiffel(Offset(size.width * 0.74 + dx, base), u, u * 7),
      ink,
    );
    // The Seine, as a decorative ribbon only.
    final river = Path()
      ..moveTo(0, base - u * 0.25)
      ..cubicTo(
        size.width * 0.3,
        base - u * 0.9,
        size.width * 0.6,
        base + u * 0.2,
        size.width,
        base - u * 0.4,
      );
    canvas.drawPath(
      river,
      Paint()
        ..color = theme.accent.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.18,
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
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.8, height: r * 1.5),
      ink,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.55, height: r * 1.25),
      ink..strokeWidth = 1.5,
    );
    canvas.drawPath(
      _eiffel(c.translate(0, r * 0.5), r * 0.22, r * 1.05),
      Paint()..color = ink.color,
    );
  }
}
