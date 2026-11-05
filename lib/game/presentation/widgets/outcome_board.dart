import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/level_result.dart';
import '../../domain/star_rating.dart';
import '../kit/game_button.dart';
import '../kit/game_fonts.dart';
import '../kit/split_flap_text.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';

/// One button on the result board.
typedef OutcomeAction = ({String label, VoidCallback onPressed, bool primary});

/// Split-flap result board shown over the platform. The system back button
/// cannot dismiss it; the player picks an action.
final class OutcomeBoard extends StatelessWidget {
  const OutcomeBoard({
    super.key,
    required this.title,
    required this.actions,
    this.result,
    this.failed = false,
  });

  final String title;
  final List<OutcomeAction> actions;
  final LevelResult? result;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rating = result?.rating;
    final accent = failed ? AppColors.danger : AppColors.accentAmber;
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF07090F),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SplitFlapText(
                  title,
                  style: TextStyle(
                    fontFamily: GameFonts.board,
                    fontWeight: FontWeight.w600,
                    fontSize: 26,
                    letterSpacing: 3,
                    color: accent,
                    shadows: [
                      Shadow(
                        color: accent.withValues(alpha: 0.7),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 14),
                  _Stars(rating: rating),
                ],
                if (result case final result?) ...[
                  const SizedBox(height: 10),
                  Text(
                    l.pulsesUsed(result.pulses),
                    style: const TextStyle(
                      fontFamily: GameFonts.board,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                for (final action in actions) ...[
                  SizedBox(
                    width: double.infinity,
                    child: GameButton(
                      label: action.label,
                      size: action.primary
                          ? GameButtonSize.large
                          : GameButtonSize.small,
                      color: action.primary
                          ? AppColors.accentTurquoise
                          : AppColors.track,
                      onPressed: action.onPressed,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stars pressed in one by one like stamps.
class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final StarRating rating;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < StarRating.gold.stars; i++)
        Icon(
              i < rating.stars ? Icons.star : Icons.star_border,
              color: AppColors.accentAmber,
              size: 44,
            )
            .animate(delay: (180 * i).ms)
            .scale(
              begin: const Offset(1.8, 1.8),
              curve: Curves.easeIn,
              duration: kArrival,
            )
            .fadeIn(duration: kArrival),
    ],
  );
}
