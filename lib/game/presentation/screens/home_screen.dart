import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../game/game_scope.dart';
import '../kit/departure_board.dart';
import '../kit/game_button.dart';
import '../kit/game_fonts.dart';
import '../kit/game_scaffold.dart';
import '../passport/passport_screen.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';
import '../widgets/game_texts.dart';
import 'city_map_screen.dart';
import 'city_select_screen.dart';
import 'level_navigation.dart';

/// The main platform: the next city's skyline, the departure board and
/// three big ticket buttons.
final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = GameScope.of(context);
    final target = store.continueTarget();
    final city = target?.level.city ?? CityId.ankara;
    return GameScaffold(
      city: city,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/branding/logo_512.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: kScreenIntro)
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 18),
            Text(
              l.brandLastTrain,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GameFonts.display,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
                color: AppColors.textPrimary,
                shadows: [
                  Shadow(
                    color: AppColors.accentTurquoise.withValues(alpha: 0.6),
                    blurRadius: 18,
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(duration: kScreenIntro),
            const SizedBox(height: 16),
            Center(
              child: DepartureBoard(
                lines: [
                  l.homeBoardLine,
                  if (target != null) l.levelCode(target.level),
                ],
              ),
            ),
            const Spacer(flex: 2),
            GameButton(
              label: l.continueGame,
              size: GameButtonSize.hero,
              onPressed: target == null
                  ? null
                  : () {
                      // Through the city map, so "back" lands on the line.
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CityMapScreen(city: target.level.city),
                        ),
                      );
                      openLevel(context, target.level, restore: target.actions);
                    },
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 12),
            GameButton(
              label: l.chooseCity,
              color: AppColors.track,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CitySelectScreen(),
                ),
              ),
            ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 12),
            GameButton(
              label: l.metroPassport,
              color: AppColors.accentAmber,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PassportScreen(passport: store.passport),
                ),
              ),
            ).animate(delay: 360.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 14),
            Text(
              l.fictionalNotice,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
