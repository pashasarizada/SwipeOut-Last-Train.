import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/level_result.dart';
import '../../domain/star_rating.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';

/// Result of a level: won (stars unless tutorial) or out of pulses.
final class LevelOutcomeSheet extends StatelessWidget {
  const LevelOutcomeSheet.won({
    super.key,
    required LevelResult this.result,
    required this.onPlayAgain,
    required this.onBackToCity,
    this.onNext,
  }) : onUndo = null;

  const LevelOutcomeSheet.lost({
    super.key,
    required VoidCallback this.onUndo,
    required this.onPlayAgain,
    required this.onBackToCity,
  }) : result = null,
       onNext = null;

  final LevelResult? result;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToCity;
  final VoidCallback? onNext;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final result = this.result;
    final rating = result?.rating;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result == null ? l.levelLost : l.levelComplete,
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: result == null
                    ? AppColors.danger
                    : AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: kArrival).slideY(begin: 0.3),
            if (rating != null) ...[
              const SizedBox(height: 12),
              _Stars(rating: rating),
            ],
            if (result != null) ...[
              const SizedBox(height: 8),
              Text(l.pulsesUsed(result.pulses), style: text.titleMedium),
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (onUndo case final undo?)
                  OutlinedButton(onPressed: undo, child: Text(l.undo)),
                OutlinedButton(
                  onPressed: onPlayAgain,
                  child: Text(l.playAgain),
                ),
                OutlinedButton(
                  onPressed: onBackToCity,
                  child: Text(l.backToCity),
                ),
                if (onNext case final next?)
                  FilledButton(onPressed: next, child: Text(l.next)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final StarRating rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < StarRating.gold.stars; i++)
          Icon(
                i < rating.stars ? Icons.star : Icons.star_border,
                color: AppColors.accentAmber,
                size: 44,
              )
              .animate(delay: (150 * i).ms)
              .scale(
                begin: const Offset(0.3, 0.3),
                curve: Curves.elasticOut,
                duration: kLevelComplete,
              )
              .fadeIn(),
      ],
    );
  }
}
