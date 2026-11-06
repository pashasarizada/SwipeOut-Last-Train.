import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../game/hint_controller.dart';
import '../game/pulse_controller.dart';
import '../kit/advance_lever.dart';
import '../kit/game_button.dart';
import '../kit/game_icon.dart';
import '../theme/app_colors.dart';
import 'game_texts.dart';

/// Undo / Restart and the big advance lever, which warns before a pulse
/// that would fail.
final class PulseControls extends StatelessWidget {
  const PulseControls({
    super.key,
    required this.controller,
    this.leverKey,
    this.undoKey,
    this.hints,
  });

  final PulseController controller;

  /// Let the tutorial hand find the lever and Undo.
  final GlobalKey? leverKey;
  final GlobalKey? undoKey;

  /// The hint button's state; none on tutorial levels (the hand guides).
  final HintController? hints;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([controller, hints]),
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
                  Expanded(
                    child: KeyedSubtree(key: undoKey, child: undo),
                  ),
                  const SizedBox(width: 12),
                  if (hints case final hints?) ...[
                    _HintButton(hints: hints, label: l.hint),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: restart),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              AdvanceLever(
                key: leverKey,
                label: l.advance,
                compact: compact,
                warning: warning,
                semanticsLabel: [
                  l.advance,
                  if (pending != null) l.pendingLabel(pending),
                  if (warning) l.forecastWarning,
                ].join(l.labelSeparator),
                onPressed: playing ? controller.advance : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A square bulb button: shows the next right move, at the cost of the
/// run's third star.
final class _HintButton extends StatelessWidget {
  const _HintButton({required this.hints, required this.label});

  final HintController hints;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 60,
    child: GameButton(
      label: '',
      semanticsLabel: label,
      size: GameButtonSize.small,
      color: AppColors.accentAmber,
      icon: const GameIcon(
        GameIconKind.bulb,
        size: 22,
        color: AppColors.background,
      ),
      onPressed: hints.canAsk ? hints.request : null,
    ),
  );
}

/// Short phones (the original iPhone SE, 568 pt) get a tighter platform so
/// the board keeps its 44 pt touch targets (D-029).
bool isCompactScreen(BuildContext context) =>
    MediaQuery.sizeOf(context).height < 700;
