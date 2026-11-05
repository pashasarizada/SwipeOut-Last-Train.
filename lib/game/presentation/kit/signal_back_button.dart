import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// A small signal post used as "back": the lamp turns green, then we leave.
final class SignalBackButton extends StatefulWidget {
  const SignalBackButton({super.key, this.onPressed});

  /// Defaults to `Navigator.maybePop`.
  final VoidCallback? onPressed;

  static const Duration _greenFor = Duration(milliseconds: 160);

  @override
  State<SignalBackButton> createState() => _SignalBackButtonState();
}

class _SignalBackButtonState extends State<SignalBackButton> {
  bool _green = false;

  Future<void> _press() async {
    if (_green) return;
    HapticFeedback.selectionClick();
    setState(() => _green = true);
    await Future<void>.delayed(SignalBackButton._greenFor);
    if (!mounted) return;
    setState(() => _green = false);
    final onPressed = widget.onPressed;
    if (onPressed != null) {
      onPressed();
    } else {
      unawaited(Navigator.maybePop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _press,
        child: SizedBox(
          width: 48,
          height: 48,
          child: CustomPaint(painter: _SignalPainter(green: _green)),
        ),
      ),
    );
  }
}

final class _SignalPainter extends CustomPainter {
  const _SignalPainter({required this.green});

  final bool green;

  @override
  void paint(Canvas canvas, Size size) {
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: size.center(const Offset(0, -2)),
        width: 20,
        height: 34,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(head, Paint()..color = AppColors.surface);
    canvas.drawRRect(
      head,
      Paint()
        ..color = AppColors.trackInactive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final top = size.center(const Offset(0, -10));
    final bottom = size.center(const Offset(0, 6));
    canvas.drawCircle(
      top,
      5.5,
      Paint()..color = green ? AppColors.trackInactive : AppColors.danger,
    );
    canvas.drawCircle(
      bottom,
      5.5,
      Paint()..color = green ? AppColors.signalGreen : AppColors.trackInactive,
    );
    // Arrow hint: this signal means "back".
    final arrow = Path()
      ..moveTo(size.width * 0.12, size.height / 2)
      ..lineTo(size.width * 0.24, size.height / 2 - 6)
      ..lineTo(size.width * 0.24, size.height / 2 + 6)
      ..close();
    canvas.drawPath(arrow, Paint()..color = AppColors.textSecondary);
  }

  @override
  bool shouldRepaint(_SignalPainter old) => old.green != green;
}
