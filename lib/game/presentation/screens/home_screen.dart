import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../data/level_repository.dart';
import '../../domain/city.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';
import 'city_select_screen.dart';
import 'level_navigation.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.repository});

  final LevelRepository repository;

  /// Until progress is saved (V2-B), "continue" starts Ankara's first level.
  Future<void> _continue(BuildContext context) async {
    final levels = await repository.loadCity(CityId.ankara);
    if (context.mounted && levels.isNotEmpty) openLevel(context, levels, 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Text(
                l.appTitle,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(duration: kScreenIntro).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                l.homeHeadline,
                textAlign: TextAlign.center,
                style: text.labelLarge?.copyWith(
                  color: AppColors.accentTurquoise,
                  letterSpacing: 3,
                ),
              ).animate(delay: 150.ms).fadeIn(duration: kScreenIntro),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: () => _continue(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(l.continueGame),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CitySelectScreen(repository: repository),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(l.chooseCity),
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
              const Spacer(),
              Text(
                l.fictionalNotice,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
