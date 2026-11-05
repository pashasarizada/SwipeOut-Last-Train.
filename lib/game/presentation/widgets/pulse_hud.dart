import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../board/train_sprite.dart';
import '../game/pulse_controller.dart';
import '../theme/app_colors.dart';
import 'game_texts.dart';

/// `LAST TRAIN · ANKARA 01`, pulse and delivery counters, controls left.
final class PulseHud extends StatelessWidget {
  const PulseHud({super.key, required this.controller});

  final PulseController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Count deliveries from the pre-pulse state until trains arrive.
        final trains = controller.animationStart.trains;
        final delivered = trains.where((t) => t.delivered).length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
          child: Row(
            children: [
              const BackButton(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.brandLastTrain} · ${l.levelCode(controller.level)}',
                      style: text.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${l.pulseCounter(controller.pulses, controller.maxPulses)} · ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              color: AppColors.accentTurquoise,
                            ),
                          ),
                        ),
                        const TrainGlyph(),
                        const SizedBox(width: 6),
                        Text(
                          l.trainsDelivered(delivered, trains.length),
                          style: text.titleMedium?.copyWith(
                            color: AppColors.accentTurquoise,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                l.controlsLeft(controller.pending == null ? 1 : 0),
                style: text.labelLarge?.copyWith(color: AppColors.accentAmber),
              ),
            ],
          ),
        );
      },
    );
  }
}
