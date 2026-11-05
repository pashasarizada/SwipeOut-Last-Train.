import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../game/pulse_controller.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';
import 'game_texts.dart';

/// Pending-control chip, Undo / Restart and the big advance button.
final class PulseControls extends StatelessWidget {
  const PulseControls({super.key, required this.controller});

  final PulseController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final idle = !controller.isAnimating;
        final playing = idle && !controller.isSolved && !controller.isLost;
        final pending = controller.pending;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: pending == null
                    ? null
                    : InputChip(
                            key: ValueKey(pending),
                            label: Text(l.pendingLabel(pending)),
                            avatar: const Icon(Icons.alt_route, size: 18),
                            onDeleted: controller.cancelPending,
                            deleteButtonTooltipMessage: l.cancel,
                          )
                          .animate()
                          .fadeIn(duration: kSwitchFlip)
                          .scale(begin: const Offset(0.85, 0.85)),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: idle && controller.canUndo
                          ? controller.undo
                          : null,
                      icon: const Icon(Icons.undo),
                      label: Text(l.undo),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: idle && controller.canUndo
                          ? controller.restart
                          : null,
                      icon: const Icon(Icons.replay),
                      label: Text(l.restart),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: playing ? controller.advance : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentTurquoise,
                    foregroundColor: AppColors.background,
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  child: Text(l.advance),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
