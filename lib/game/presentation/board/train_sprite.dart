import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/train_def.dart';
import '../kit/game_fonts.dart';
import '../theme/app_colors.dart';

/// Screen angle (radians, 0 = east, clockwise positive) from [from] to [to].
double headingOf(Offset from, Offset to) =>
    math.atan2(to.dy - from.dy, to.dx - from.dx);

/// A top-down metro car drawn by us (no emoji): rounded nose, window strip,
/// livery stripe in the train's colour, headlights with a light cone. The
/// car turns with [heading]; its symbol stays upright so it is always read.
final class TrainSprite extends StatelessWidget {
  const TrainSprite({
    super.key,
    required this.train,
    required this.heading,
    this.headlights = 1,
    this.length = 34,
  });

  final TrainDef train;
  final double heading;

  /// 0–1: dimmed while waiting, full while moving.
  final double headlights;
  final double length;

  @override
  Widget build(BuildContext context) {
    final color = colorForStyle(train.style);
    return SizedBox.square(
      dimension: length * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: heading,
            child: CustomPaint(
              size: Size.square(length * 1.6),
              painter: _CarPainter(
                color: color,
                headlights: headlights,
                length: length,
              ),
            ),
          ),
          Container(
            width: length * 0.46,
            height: length * 0.46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Text(
              train.symbol.glyph,
              style: TextStyle(
                fontFamily: GameFonts.body,
                color: color,
                fontSize: length * 0.28,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _CarPainter extends CustomPainter {
  const _CarPainter({
    required this.color,
    required this.headlights,
    required this.length,
  });

  final Color color;
  final double headlights;
  final double length;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = length * 0.56;
    final body = Rect.fromCenter(center: c, width: length, height: w);
    final nose = Radius.circular(w * 0.5);
    final tail = Radius.circular(w * 0.22);
    final shape = RRect.fromRectAndCorners(
      body,
      topRight: nose,
      bottomRight: nose,
      topLeft: tail,
      bottomLeft: tail,
    );

    if (headlights > 0) {
      final cone = Path()
        ..moveTo(body.right - w * 0.1, c.dy - w * 0.3)
        ..lineTo(body.right + length * 0.55, c.dy - w * 0.75)
        ..lineTo(body.right + length * 0.55, c.dy + w * 0.75)
        ..lineTo(body.right - w * 0.1, c.dy + w * 0.3)
        ..close();
      canvas.drawPath(
        cone,
        Paint()
          ..shader =
              LinearGradient(
                colors: [
                  AppColors.accentAmber.withValues(alpha: 0.45 * headlights),
                  AppColors.accentAmber.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromLTWH(body.right, c.dy - w, length * 0.55, w * 2),
              ),
      );
    }

    canvas.drawRRect(
      shape.shift(const Offset(0, 2)),
      Paint()..color = const Color(0x66000000),
    );
    canvas.drawRRect(shape, Paint()..color = const Color(0xFFDDE3F0));
    // Livery stripe along both sides.
    final stripe = Paint()..color = color;
    canvas.drawRect(
      Rect.fromLTWH(body.left + 2, body.top + 1, length * 0.7, w * 0.18),
      stripe,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        body.left + 2,
        body.bottom - 1 - w * 0.18,
        length * 0.7,
        w * 0.18,
      ),
      stripe,
    );
    // Cab window at the nose.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          body.right - w * 0.42,
          c.dy - w * 0.28,
          w * 0.26,
          w * 0.56,
        ),
        Radius.circular(w * 0.12),
      ),
      Paint()..color = AppColors.background,
    );
    final lamp = Paint()
      ..color = Color.lerp(
        AppColors.trackInactive,
        AppColors.accentAmber,
        headlights,
      )!;
    canvas.drawCircle(
      Offset(body.right - w * 0.08, c.dy - w * 0.3),
      w * 0.09,
      lamp,
    );
    canvas.drawCircle(
      Offset(body.right - w * 0.08, c.dy + w * 0.3),
      w * 0.09,
      lamp,
    );
  }

  @override
  bool shouldRepaint(_CarPainter old) =>
      old.color != color ||
      old.headlights != headlights ||
      old.length != length;
}

/// Small side-view metro car for counters and labels (replaces 🚆).
final class TrainGlyph extends StatelessWidget {
  const TrainGlyph({
    super.key,
    this.size = 16,
    this.color = AppColors.accentTurquoise,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size * 1.5, size), painter: _GlyphPainter(color));
}

final class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, h * 0.1, size.width, h * 0.7),
      topRight: Radius.circular(h * 0.35),
      topLeft: Radius.circular(h * 0.12),
      bottomLeft: Radius.circular(h * 0.12),
      bottomRight: Radius.circular(h * 0.12),
    );
    canvas.drawRRect(body, Paint()..color = color);
    final window = Paint()..color = AppColors.background;
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (0.12 + 0.24 * i),
          h * 0.25,
          size.width * 0.16,
          h * 0.2,
        ),
        window,
      );
    }
    final wheel = Paint()..color = AppColors.textSecondary;
    canvas.drawCircle(Offset(size.width * 0.25, h * 0.88), h * 0.1, wheel);
    canvas.drawCircle(Offset(size.width * 0.75, h * 0.88), h * 0.1, wheel);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}
