import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'city_theme.dart';

enum AmbientEffect { dust, waves, lamps, rain, snow }

/// A city's own artwork (docs/ART_DIRECTION.md "Şehir sanatı"). Adding a
/// city means adding a class, not editing the others (OCP).
abstract interface class CityArt {
  /// Faint repeating motif behind everything.
  void paintPattern(Canvas canvas, Size size, CityTheme theme);

  /// Stylised skyline along the bottom; [parallax] shifts it sideways.
  void paintSkyline(
    Canvas canvas,
    Size size,
    CityTheme theme, {
    double parallax = 0,
  });

  /// Ambient effect frame for animation phase [t] in 0–1.
  void paintAmbient(Canvas canvas, Size size, CityTheme theme, double t);

  /// The Metro Passport stamp for this city.
  void paintStamp(
    Canvas canvas,
    Size size,
    CityTheme theme, {
    required bool gold,
  });

  AmbientEffect get ambient;
}

/// Shared drawing helpers and the ambient effects (DRY).
abstract base class CityArtBase implements CityArt {
  const CityArtBase();

  static const Color gold = Color(0xFFD4AF37);

  /// Calls [draw] at the centre of every tile of a [step]-sized grid.
  static void tile(
    Canvas canvas,
    Size size,
    double step,
    void Function(Offset c, int i) draw,
  ) {
    var i = 0;
    for (var y = step / 2; y < size.height + step; y += step) {
      for (var x = step / 2; x < size.width + step; x += step) {
        draw(Offset(x, y), i++);
      }
    }
  }

  static Paint patternPaint(CityTheme theme) => Paint()
    ..color = theme.accentAlt.withValues(alpha: 0.07)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  static Paint silhouette(CityTheme theme) =>
      Paint()
        ..color = Color.lerp(theme.background, const Color(0xFF000000), 0.55)!;

  /// City-coloured glow on the horizon so dark skylines stand out.
  static void horizonGlow(Canvas canvas, Size size, CityTheme theme) {
    final area = Rect.fromLTRB(0, size.height * 0.55, size.width, size.height);
    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.accent.withValues(alpha: 0.30),
            theme.accent.withValues(alpha: 0),
          ],
        ).createShader(area),
    );
  }

  /// Scale unit for skylines: relative to width, capped by height.
  static double unit(Size size) => math.min(size.width, size.height * 0.7) / 10;

  /// Warm lit windows on a block.
  static void windows(Canvas canvas, Rect block, CityTheme theme, int seed) {
    final lit = Paint()..color = theme.accentAlt.withValues(alpha: 0.55);
    final w = block.width / 7;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 3; c++) {
        if ((seed + r * 3 + c * 7) % 3 != 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            block.left + w * (1 + c * 2),
            block.top + w * (1 + r * 2),
            w,
            w,
          ),
          lit,
        );
      }
    }
  }

  /// Double-ring stamp frame in ink (or gold) used by every city.
  static Paint stampInk(CityTheme theme, {required bool gold}) => Paint()
    ..color = (gold ? CityArtBase.gold : theme.accent).withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  static void stampRings(Canvas canvas, Size size, Paint ink) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r * 0.94, ink);
    canvas.drawCircle(c, r * 0.80, ink..strokeWidth = 1.5);
    ink.strokeWidth = 3;
  }

  /// [t] runs 0 → 1 and then starts again, so every motion here is a whole
  /// number of cycles per loop: at t = 1 everything is back where it began.
  @override
  void paintAmbient(Canvas canvas, Size size, CityTheme theme, double t) {
    final rnd = math.Random(ambient.index);
    final paint = Paint()..color = theme.accentAlt.withValues(alpha: 0.35);
    switch (ambient) {
      case AmbientEffect.dust:
        for (var i = 0; i < 40; i++) {
          final x =
              (rnd.nextDouble() +
                  math.sin((t * (i % 3 + 1) + i / 7) * math.pi * 2) * 0.04) %
              1;
          final y =
              (rnd.nextDouble() + math.sin((t + i) * math.pi * 2) * 0.01) % 1;
          canvas.drawCircle(
            Offset(x * size.width, y * size.height),
            1.1,
            paint,
          );
        }
      case AmbientEffect.waves:
        final wave = Paint()
          ..color = theme.accent.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        for (var k = 0; k < 4; k++) {
          final y = size.height * (0.80 + k * 0.045);
          final path = Path()..moveTo(0, y);
          for (var x = 0.0; x <= size.width; x += 8) {
            path.lineTo(x, y + math.sin(x / 26 + t * math.pi * 2 + k) * 3);
          }
          canvas.drawPath(path, wave);
        }
      case AmbientEffect.lamps:
        for (var i = 0; i < 9; i++) {
          final c = Offset(
            rnd.nextDouble() * size.width,
            size.height * (0.55 + rnd.nextDouble() * 0.3),
          );
          final glow = 0.25 + 0.2 * math.sin((t + i / 9) * math.pi * 2);
          canvas.drawCircle(
            c,
            16,
            Paint()
              ..color = theme.accent.withValues(alpha: glow)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          );
        }
      case AmbientEffect.rain:
        final drop = Paint()
          ..color = theme.rail.withValues(alpha: 0.22)
          ..strokeWidth = 1;
        for (var i = 0; i < 70; i++) {
          final x = rnd.nextDouble() * size.width;
          final y = (rnd.nextDouble() + t * (i % 3 + 1)) % 1 * size.height;
          canvas.drawLine(Offset(x, y), Offset(x - 3, y + 12), drop);
        }
      case AmbientEffect.snow:
        final flake = Paint()..color = const Color(0xCCFFFFFF);
        for (var i = 0; i < 60; i++) {
          final x =
              (rnd.nextDouble() + math.sin((t + i) * math.pi * 2) * 0.02) % 1;
          final y = (rnd.nextDouble() + t * (i % 2 + 1)) % 1;
          canvas.drawCircle(
            Offset(x * size.width, y * size.height),
            1 + i % 3 * 0.6,
            flake,
          );
        }
    }
  }
}
