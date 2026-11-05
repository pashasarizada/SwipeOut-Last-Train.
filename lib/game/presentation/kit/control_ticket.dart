import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'game_fonts.dart';

/// The pending control shown as a punched ticket. Swipe it left or tap the
/// cross to tear it up (cancel).
final class ControlTicket extends StatelessWidget {
  const ControlTicket({
    super.key,
    required this.label,
    required this.onTear,
    this.tearLabel = 'Cancel',
  });

  static const Key tearKey = ValueKey('control-ticket-tear');
  static const double _tearDistance = 40;

  final String label;
  final VoidCallback onTear;
  final String tearLabel;

  @override
  Widget build(BuildContext context) {
    var dragged = 0.0;
    return GestureDetector(
      onHorizontalDragStart: (_) => dragged = 0,
      onHorizontalDragUpdate: (d) => dragged += d.delta.dx,
      onHorizontalDragEnd: (_) {
        if (dragged <= -_tearDistance) onTear();
      },
      child: CustomPaint(
        painter: const _TicketPainter(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.alt_route,
                size: 18,
                color: AppColors.accentAmber,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: GameFonts.board,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Semantics(
                button: true,
                label: tearLabel,
                excludeSemantics: true,
                child: GestureDetector(
                  key: tearKey,
                  behavior: HitTestBehavior.opaque,
                  onTap: onTear,
                  child: const SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ticket outline with a punched notch on each side and a perforation line.
final class _TicketPainter extends CustomPainter {
  const _TicketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final notch = size.height * 0.18;
    final ticket = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      );
    final holes = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, size.height / 2), radius: notch),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, size.height / 2),
          radius: notch,
        ),
      );
    final shape = Path.combine(PathOperation.difference, ticket, holes);
    canvas.drawPath(shape, Paint()..color = AppColors.surface);
    canvas.drawPath(
      shape,
      Paint()
        ..color = AppColors.accentAmber.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final dash = Paint()
      ..color = AppColors.trackInactive
      ..strokeWidth = 1.5;
    final x = size.width - 44;
    for (var y = 6.0; y < size.height - 6; y += 6) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 3), dash);
    }
  }

  @override
  bool shouldRepaint(_TicketPainter old) => false;
}
