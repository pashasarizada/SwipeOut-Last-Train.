import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../data/level_repository.dart';
import '../theme/app_colors.dart';
import 'level_list_screen.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.repository});

  final LevelRepository repository;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.appTitle,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.cityIstanbul,
                textAlign: TextAlign.center,
                style: text.labelLarge?.copyWith(
                  color: AppColors.accentTurquoise,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LevelListScreen(repository: repository),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l.play),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
