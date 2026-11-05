import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../game/pulse_controller.dart';
import '../kit/advance_lever.dart';
import '../kit/control_ticket.dart';
import '../kit/game_button.dart';
import '../theme/app_colors.dart';
import 'game_texts.dart';

/// Pending-control ticket, Undo / Restart and the big advance lever.
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 52,
                child: pending == null
                    ? null
                    : Center(
                        child: ControlTicket(
                          key: ValueKey(pending),
                          label: l.pendingLabel(pending),
                          tearLabel: l.cancel,
                          onTear: controller.cancelPending,
                        ),
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GameButton(
                      label: l.undo,
                      size: GameButtonSize.small,
                      color: AppColors.track,
                      onPressed: idle && controller.canUndo
                          ? controller.undo
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GameButton(
                      label: l.restart,
                      size: GameButtonSize.small,
                      color: AppColors.track,
                      onPressed: idle && controller.canUndo
                          ? controller.restart
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AdvanceLever(
                label: l.advance,
                onPressed: playing ? controller.advance : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
