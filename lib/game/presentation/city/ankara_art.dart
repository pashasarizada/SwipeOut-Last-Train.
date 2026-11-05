import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'city_art.dart';
import 'city_theme.dart';

/// Ankara: Hittite sun-disc rings, citadel walls, a colonnade and a tower.
final class AnkaraArt extends CityArtBase {
  const AnkaraArt();

  @override
  AmbientEffect get ambient => AmbientEffect.dust;

  @override
  void paintPattern(Canvas canvas, Size size, CityTheme theme) {
    final p = CityArtBase.patternPaint(theme);
    CityArtBase.tile(canvas, size, 96, (c, i) {
      canvas.drawCircle(c, 26, p);
      canvas.drawCircle(c, 14, p);
      for (var k = 0; k < 12; k++) {
        final a = k * math.pi / 6;
        canvas.drawLine(
          c + Offset.fromDirection(a, 16),
          c + Offset.fromDirection(a, 24),
          p,
        );
      }
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
    // Citadel wall with crenellations and two towers.
    final wall = Path()..moveTo(-u + dx, base);
    for (var x = -u; x < size.width * 0.45; x += u * 0.6) {
      wall
        ..lineTo(x + dx, base - u * 1.6)
        ..lineTo(x + dx + u * 0.3, base - u * 1.6)
        ..lineTo(x + dx + u * 0.3, base - u * 1.9)
        ..lineTo(x + dx + u * 0.6, base - u * 1.9);
    }
    wall
      ..lineTo(size.width * 0.45 + dx, base)
      ..close();
    canvas.drawPath(wall, ink);
    for (final tx in [0.08, 0.32]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * tx + dx, base - u * 2.8, u * 0.9, u * 2.8),
        ink,
      );
    }
    // Colonnade rhythm.
    final left = size.width * 0.48 + dx;
    canvas.drawRect(Rect.fromLTWH(left, base - u * 2.2, u * 3.2, u * 0.3), ink);
    for (var k = 0; k < 7; k++) {
      canvas.drawRect(
        Rect.fromLTWH(
          left + u * 0.1 + k * u * 0.45,
          base - u * 1.9,
          u * 0.22,
          u * 1.9,
        ),
        ink,
      );
    }
    // Tower: tapering shaft and a wide observation head with a lit band.
    final tower = size.width * 0.86 + dx;
    final shaft = Path()
      ..moveTo(tower - u * 0.45, base)
      ..lineTo(tower - u * 0.22, base - u * 5.0)
      ..lineTo(tower + u * 0.22, base - u * 5.0)
      ..lineTo(tower + u * 0.45, base)
      ..close();
    canvas.drawPath(shaft, ink);
    final head = Rect.fromCenter(
      center: Offset(tower, base - u * 5.4),
      width: u * 1.7,
      height: u * 1.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(head, Radius.circular(u * 0.35)),
      ink,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: head.center,
        width: head.width * 0.8,
        height: u * 0.16,
      ),
      Paint()..color = theme.accentAlt.withValues(alpha: 0.8),
    );
    canvas.drawRect(
      Rect.fromLTWH(tower - u * 0.05, head.top - u * 0.9, u * 0.1, u * 0.9),
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
    canvas.drawCircle(c, r * 0.32, ink);
    for (var k = 0; k < 16; k++) {
      final a = k * math.pi / 8;
      canvas.drawLine(
        c + Offset.fromDirection(a, r * 0.40),
        c + Offset.fromDirection(a, r * 0.66),
        ink,
      );
    }
  }
}
