import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'game_fonts.dart';
import 'split_flap_text.dart';

/// Amber departure board: dark panel, faint dot matrix, split-flap lines.
final class DepartureBoard extends StatelessWidget {
  const DepartureBoard({
    super.key,
    required this.lines,
    this.color = AppColors.accentAmber,
  });

  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DotMatrixPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, line) in lines.indexed)
              SplitFlapText(
                line,
                style: TextStyle(
                  fontFamily: GameFonts.board,
                  fontWeight: FontWeight.w600,
                  fontSize: i == 0 ? 15 : 13,
                  letterSpacing: 1.6,
                  color: i == 0 ? color : color.withValues(alpha: 0.85),
                  shadows: [
                    Shadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _DotMatrixPainter extends CustomPainter {
  const _DotMatrixPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final panel = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(panel, Paint()..color = const Color(0xFF07090F));
    final dot = Paint()..color = const Color(0x14FFFFFF);
    for (var x = 3.0; x < size.width; x += 4) {
      for (var y = 3.0; y < size.height; y += 4) {
        canvas.drawCircle(Offset(x, y), 0.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_DotMatrixPainter old) => false;
}
