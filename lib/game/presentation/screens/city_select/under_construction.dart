part of '../city_select_screen.dart';

/// Barrier tape across a city that is not open yet (never "for sale").
final class _UnderConstruction extends StatelessWidget {
  const _UnderConstruction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.rotate(
      angle: -0.18,
      child: CustomPaint(
        painter: const _TapePainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: GameFonts.board,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    ),
  );
}

final class _TapePainter extends CustomPainter {
  const _TapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-40, 0, size.width + 80, size.height);
    canvas.drawRect(rect, Paint()..color = AppColors.accentAmber);
    final stripe = Paint()
      ..color = AppColors.background.withValues(alpha: 0.85);
    for (var x = rect.left; x < rect.right; x += 26) {
      canvas.drawPath(
        Path()
          ..moveTo(x, rect.bottom)
          ..lineTo(x + 10, rect.bottom)
          ..lineTo(x + 18, rect.bottom - 6)
          ..lineTo(x + 8, rect.bottom - 6)
          ..close(),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_TapePainter old) => false;
}
