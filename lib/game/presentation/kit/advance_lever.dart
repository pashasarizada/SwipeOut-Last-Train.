import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'game_button.dart';

/// The big "advance one minute" control at the bottom of the platform:
/// a hero-sized game button with a clock mark and a medium thump.
final class AdvanceLever extends StatelessWidget {
  const AdvanceLever({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GameButton(
        label: label,
        onPressed: onPressed,
        size: GameButtonSize.hero,
        haptic: HapticFeedback.mediumImpact,
        icon: const SizedBox.square(
          dimension: 26,
          child: CustomPaint(painter: _ClockPainter()),
        ),
      ),
    );
  }
}

final class _ClockPainter extends CustomPainter {
  const _ClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final ink = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r - 1.5, ink);
    canvas.drawLine(c, c.translate(0, -r * 0.55), ink);
    canvas.drawLine(c, c.translate(r * 0.45, 0), ink);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => false;
}
