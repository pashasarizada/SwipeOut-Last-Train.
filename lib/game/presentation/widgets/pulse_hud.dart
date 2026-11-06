import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../city/city_theme.dart';
import '../game/pulse_controller.dart';
import '../kit/departure_board.dart';
import '../kit/game_icon.dart';
import '../kit/signal_back_button.dart';
import '../theme/app_colors.dart';
import 'game_texts.dart';
import 'run_meter.dart';

/// The platform's departure board (line, level and the clock, which runs
/// out at midnight) above the drawn [RunMeter] of trains and minutes.
final class PulseHud extends StatelessWidget {
  const PulseHud({
    super.key,
    required this.controller,
    this.onBoardTap,
    this.rulesHidden = false,
  });

  final PulseController controller;

  /// Tapping the departure board (brings the level's rules back).
  final VoidCallback? onBoardTap;

  /// The level has rules that are not on screen: a small "i" on the board
  /// says a tap brings them back (playtest: nobody found it).
  final bool rulesHidden;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final level = controller.level;
    final theme = CityTheme.of(level.city);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Count deliveries from the pre-pulse state until trains arrive.
        final trains = controller.animationStart.trains;
        final delivered = trains.where((t) => t.delivered).length;
        final meter = RunMeter(
          trains: [
            for (final t in trains)
              TrainMark(
                style: level.trainDef(t.id)!.style,
                delivered: t.delivered,
              ),
          ],
          used: controller.pulses,
          max: controller.maxPulses,
          par: level.tutorial ? null : level.parPulses,
          semanticsLabel: l.meterLabel(
            l.pulseCounter(controller.pulses, controller.maxPulses),
            l.trainsDelivered(delivered, trains.length),
          ),
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
          child: Row(
            children: [
              const SignalBackButton(),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBoardTap,
                      excludeFromSemantics: true,
                      child: Semantics(
                        button: onBoardTap != null,
                        onTap: onBoardTap,
                        onTapHint: onBoardTap == null ? null : l.showRulesAgain,
                        // Sized to the board, so the badge sits on its
                        // corner rather than the row's far edge.
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              DepartureBoard(
                                color: theme.accentAlt,
                                lines: [
                                  '${l.levelCode(level)} · '
                                      '${level.title.of(language)}',
                                  [
                                    GameTexts.clock(
                                      controller.pulses,
                                      max: controller.maxPulses,
                                    ),
                                    if (!level.tutorial)
                                      controller.hintUsed
                                          ? l.goalHintCapped
                                          : l.goalGold(level.parPulses),
                                  ].join(' · '),
                                ],
                              ),
                              // A badge on the board's corner, clear of the
                              // text however long the lines run.
                              if (rulesHidden && onBoardTap != null)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: GameIcon(
                                      GameIconKind.info,
                                      size: 18,
                                      color: theme.accentAlt,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: meter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
