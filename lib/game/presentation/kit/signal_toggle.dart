import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'game_haptics.dart';

/// An on/off switch drawn as a two-lamp signal head lying on its side: red
/// on the left when off, green on the right when on. No Material switch.
final class SignalToggle extends StatelessWidget {
  const SignalToggle({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;

  /// What the switch controls, for screen readers.
  final String label;
  final ValueChanged<bool> onChanged;

  static const Duration _slide = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    final lit = value ? AppColors.signalGreen : AppColors.danger;
    return Semantics(
      label: label,
      toggled: value,
      button: false,
      enabled: true,
      excludeSemantics: true,
      onTap: () => _flip(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _flip(context),
        child: SizedBox(
          width: 76,
          height: 48,
          child: Center(
            child: Container(
              width: 68,
              height: 34,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.track, width: 2),
              ),
              child: AnimatedAlign(
                duration: _slide,
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: _slide,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lit,
                    boxShadow: [
                      BoxShadow(
                        color: lit.withValues(alpha: 0.6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _flip(BuildContext context) {
    GameHaptics.play(context, HapticKind.selection);
    onChanged(!value);
  }
}
