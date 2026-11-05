import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../data/level_repository.dart';
import '../../domain/city.dart';
import '../../domain/level_definition.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'city_levels_screen.dart';

/// Five city cards, easiest first. Cities without levels are "coming soon".
final class CitySelectScreen extends StatefulWidget {
  const CitySelectScreen({super.key, required this.repository});

  final LevelRepository repository;

  @override
  State<CitySelectScreen> createState() => _CitySelectScreenState();
}

class _CitySelectScreenState extends State<CitySelectScreen> {
  late final Future<Map<CityId, List<LevelDefinition>>> _cities = _load();

  Future<Map<CityId, List<LevelDefinition>>> _load() async => {
    for (final city in CityId.values)
      city: await widget.repository.loadCity(city),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.chooseCity)),
      body: FutureBuilder(
        future: _cities,
        builder: (context, snapshot) {
          final cities = snapshot.data;
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (cities == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (i, city) in CityId.values.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CityCard(city: city, levels: cities[city]!),
                ).animate(delay: (70 * i).ms).fadeIn().slideY(begin: 0.15),
              Text(
                l.fictionalNotice,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({required this.city, required this.levels});

  final CityId city;
  final List<LevelDefinition> levels;

  @override
  Widget build(BuildContext context) {
    final available = levels.isNotEmpty;
    return OpenContainer<void>(
      tappable: available,
      closedColor: AppColors.surface,
      openColor: AppColors.background,
      middleColor: AppColors.surface,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      openBuilder: (_, _) => CityLevelsScreen(city: city, levels: levels),
      closedBuilder: (context, _) =>
          _CardFace(city: city, available: available),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.city, required this.available});

  final CityId city;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final muted = available ? AppColors.textPrimary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.cityName(city),
                  style: text.titleLarge?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                if (city == CityId.moscow)
                  Text(
                    l.nightmareNetwork,
                    style: text.labelSmall?.copyWith(color: AppColors.danger),
                  ),
                if (!available)
                  Text(
                    l.comingSoon,
                    style: text.labelMedium?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
          Text(
            '★' * city.difficulty +
                '☆' * (CityId.values.length - city.difficulty),
            style: const TextStyle(color: AppColors.accentAmber, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
