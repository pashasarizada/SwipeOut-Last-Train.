import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/level_result.dart';
import '../../domain/star_rating.dart';
import '../theme/app_colors.dart';

final class LevelCompleteSheet extends StatelessWidget {
  const LevelCompleteSheet({
    super.key,
    required this.result,
    required this.onReplay,
    this.onNext,
  });

  final LevelResult result;
  final VoidCallback onReplay;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final earned = result.rating.stars;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.levelComplete, style: text.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < StarRating.gold.stars; i++)
                  Icon(
                    i < earned ? Icons.star : Icons.star_border,
                    color: AppColors.accentAmber,
                    size: 40,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.moves(result.moves), style: text.titleMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReplay,
                    child: Text(l.replay),
                  ),
                ),
                if (onNext != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(onPressed: onNext, child: Text(l.next)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
