import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../theme/app_colors.dart';

/// The Last Train emblem: a metro car nose with two headlights over
/// converging rails. One source for the app icon, launch image and UI.
final class EmblemPainter extends CustomPainter {
  const EmblemPainter({this.withBackground = true});

  /// The app icon needs an opaque background; the launch image does not.
  final bool withBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final c = Offset(size.width / 2, size.height / 2);
    if (withBackground) _paintBackground(canvas, size, c, s);
    _paintRails(canvas, c, s);
    _paintCar(canvas, c, s);
  }

  void _paintBackground(Canvas canvas, Size size, Offset c, double s) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF1B2446), AppColors.background],
        ).createShader(Rect.fromCircle(center: c, radius: s * 0.75)),
    );
  }

  void _paintRails(Canvas canvas, Offset c, double s) {
    final rail = Paint()
      ..color = AppColors.track.withValues(alpha: 0.8)
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    final bottom = c.dy + s * 0.46;
    final horizon = c.dy + s * 0.18;
    for (final side in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(c.dx + side * s * 0.36, bottom),
        Offset(c.dx + side * s * 0.12, horizon),
        rail,
      );
    }
    final sleeper = Paint()
      ..color = AppColors.trackInactive
      ..strokeWidth = s * 0.018;
    for (var i = 0; i < 4; i++) {
      final t = i / 4;
      final y = bottom - (bottom - horizon) * t;
      final half = s * (0.40 - 0.26 * t);
      canvas.drawLine(Offset(c.dx - half, y), Offset(c.dx + half, y), sleeper);
    }
  }

  void _paintCar(Canvas canvas, Offset c, double s) {
    final body = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: c.translate(0, -s * 0.04),
        width: s * 0.52,
        height: s * 0.50,
      ),
      topLeft: Radius.circular(s * 0.20),
      topRight: Radius.circular(s * 0.20),
      bottomLeft: Radius.circular(s * 0.07),
      bottomRight: Radius.circular(s * 0.07),
    );
    canvas.drawRRect(
      body.shift(Offset(0, s * 0.02)),
      Paint()..color = const Color(0x66000000),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.accentTurquoise);

    final windshield = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: c.translate(0, -s * 0.12),
        width: s * 0.38,
        height: s * 0.16,
      ),
      Radius.circular(s * 0.06),
    );
    canvas.drawRRect(windshield, Paint()..color = AppColors.background);

    canvas.drawRect(
      Rect.fromCenter(
        center: c.translate(0, s * 0.06),
        width: s * 0.52,
        height: s * 0.04,
      ),
      Paint()..color = AppColors.accentRed,
    );

    for (final side in [-1.0, 1.0]) {
      final light = c.translate(side * s * 0.15, s * 0.14);
      canvas.drawCircle(
        light,
        s * 0.09,
        Paint()
          ..color = AppColors.accentAmber.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.04),
      );
      canvas.drawCircle(
        light,
        s * 0.045,
        Paint()..color = AppColors.accentAmber,
      );
    }
  }

  @override
  bool shouldRepaint(EmblemPainter old) => old.withBackground != withBackground;
}
