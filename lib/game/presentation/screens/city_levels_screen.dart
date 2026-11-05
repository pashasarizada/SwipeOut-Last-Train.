import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../../domain/level_definition.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'level_navigation.dart';

/// The levels of one city, in order.
final class CityLevelsScreen extends StatelessWidget {
  const CityLevelsScreen({super.key, required this.city, required this.levels});

  final CityId city;
  final List<LevelDefinition> levels;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.cityName(city))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => ListTile(
          tileColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: const Icon(Icons.tram, color: AppColors.accentTurquoise),
          title: Text(
            '${l.levelCode(levels[i])} · ${levels[i].title.of(language)}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openLevel(context, levels, i),
        ).animate(delay: (60 * i).ms).fadeIn().slideX(begin: 0.12),
      ),
    );
  }
}
