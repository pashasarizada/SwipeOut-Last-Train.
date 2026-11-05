import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'game_fonts.dart';

enum GameButtonSize {
  small(48, 14),
  large(60, 17),
  hero(72, 19);

  const GameButtonSize(this.height, this.fontSize);

  final double height;
  final double fontSize;
}

/// A physical "ticket" button: the face sinks 3 pt onto its base while
/// pressed, springs back, and clicks. Replaces Material buttons.
final class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = GameButtonSize.large,
    this.color = AppColors.accentTurquoise,
    this.haptic = HapticFeedback.selectionClick,
  });

  static const Key faceKey = ValueKey('game-button-face');
  static const double _depth = 3;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final GameButtonSize size;
  final Color color;
  final Future<void> Function() haptic;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null;

  void _setDown(bool down) {
    if (_enabled && _down != down) setState(() => _down = down);
  }

  void _fire() {
    widget.haptic();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final base = Color.lerp(color, Colors.black, 0.55)!;
    final radius = BorderRadius.circular(18);
    // The decoration (and its shadow) never animates: lerping a shadow list
    // with an overshooting curve produces a negative blur and an assertion.
    // Only the position springs.
    final face = TweenAnimationBuilder<double>(
      tween: Tween(end: _down ? GameButton._depth : 0),
      duration: Duration(milliseconds: _down ? 80 : 160),
      curve: _down ? Curves.easeOut : Curves.easeOutBack,
      builder: (context, dy, child) =>
          Transform.translate(offset: Offset(0, dy), child: child),
      child: Container(
        key: GameButton.faceKey,
        height: widget.size.height,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, Colors.white, 0.18)!, color],
          ),
          border: Border.all(
            color: Color.lerp(color, Colors.white, 0.45)!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.30), blurRadius: 16),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon case final icon?) ...[
              icon,
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: GameFonts.display,
                  fontSize: widget.size.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      child: Opacity(
        opacity: _enabled ? 1 : 0.4,
        // Raw pointer events give an instant press; the tap recogniser
        // decides whether it counts.
        child: Listener(
          onPointerDown: (_) => _setDown(true),
          onPointerUp: (_) => _setDown(false),
          onPointerCancel: (_) => _setDown(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled ? _fire : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: Container(
                padding: const EdgeInsets.only(bottom: GameButton._depth),
                decoration: BoxDecoration(color: base, borderRadius: radius),
                child: face,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
