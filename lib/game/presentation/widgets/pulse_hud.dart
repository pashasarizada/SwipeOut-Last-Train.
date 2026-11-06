import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../city/city_theme.dart';
import '../game/pulse_controller.dart';
import '../kit/departure_board.dart';
import '../kit/signal_back_button.dart';
import 'game_texts.dart';
import 'run_meter.dart';

/// The platform's departure board (line, level and the clock: 23:50 + one
/// minute per pulse) above the drawn [RunMeter] of trains and minutes.
final class PulseHud extends StatelessWidget {
  const PulseHud({super.key, required this.controller});

  final PulseController controller;

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
          semanticsLabel:
              '${l.pulseCounter(controller.pulses, controller.maxPulses)} · '
              '${l.trainsDelivered(delivered, trains.length)}',
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
                    DepartureBoard(
                      color: theme.accentAlt,
                      lines: [
                        '${l.levelCode(level)} · ${level.title.of(language)}',
                        GameTexts.clock(controller.pulses),
                      ],
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
