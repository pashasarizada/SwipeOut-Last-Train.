import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../game/pulse_controller.dart';
import '../kit/advance_lever.dart';
import '../kit/game_button.dart';
import '../theme/app_colors.dart';
import 'game_texts.dart';

/// Undo / Restart and the big advance lever, which warns before a pulse
/// that would fail.
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
        final compact = isCompactScreen(context);
        final warning = !(controller.forecast?.ok ?? true);
        final undo = GameButton(
          label: l.undo,
          size: GameButtonSize.small,
          color: AppColors.track,
          onPressed: idle && controller.canUndo ? controller.undo : null,
        );
        final restart = GameButton(
          label: l.restart,
          size: GameButtonSize.small,
          color: AppColors.track,
          onPressed: idle && controller.canUndo ? controller.restart : null,
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, compact ? 6 : 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: undo),
                  const SizedBox(width: 12),
                  Expanded(child: restart),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              AdvanceLever(
                label: l.advance,
                compact: compact,
                warning: warning,
                semanticsLabel: [
                  l.advance,
                  if (pending != null) l.pendingLabel(pending),
                  if (warning) l.forecastWarning,
                ].join('. '),
                onPressed: playing ? controller.advance : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Short phones (the original iPhone SE, 568 pt) get a tighter platform so
/// the board keeps its 44 pt touch targets (D-029).
bool isCompactScreen(BuildContext context) =>
    MediaQuery.sizeOf(context).height < 700;
