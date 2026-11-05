import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../game/game_controller.dart';
import '../theme/app_colors.dart';

/// Bottom bar with Undo, Restart and Hint.
final class GameControls extends StatelessWidget {
  const GameControls({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final idle = !controller.isBusy;
        final playing = idle && !controller.isSolved;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              _ControlButton(
                icon: Icons.undo,
                label: l.undo,
                onPressed: idle && controller.canUndo ? controller.undo : null,
              ),
              _ControlButton(
                icon: Icons.replay,
                label: l.restart,
                onPressed: idle && controller.canUndo
                    ? controller.restart
                    : null,
              ),
              _ControlButton(
                icon: Icons.lightbulb_outline,
                label: l.hint,
                onPressed: playing ? controller.requestHint : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.trackInactive
        : AppColors.textPrimary;
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
