import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'game_texts.dart';

/// Top bar: `LAST TRAIN / ISTANBUL · LEVEL 07` and the move counter.
final class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.levelNumber, required this.moves});

  final int levelNumber;
  final int moves;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l.brandLastTrain} / ${l.cityIstanbul} · ${l.levelTitle(levelNumber)}',
              style: text.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            l.moves(moves),
            style: text.titleMedium?.copyWith(color: AppColors.accentTurquoise),
          ),
        ],
      ),
    );
  }
}
