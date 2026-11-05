import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../data/level_repository.dart';
import '../../domain/level_definition.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'game_screen.dart';

final class LevelListScreen extends StatefulWidget {
  const LevelListScreen({super.key, required this.repository});

  final LevelRepository repository;

  @override
  State<LevelListScreen> createState() => _LevelListScreenState();
}

class _LevelListScreenState extends State<LevelListScreen> {
  late final Future<List<LevelDefinition>> _levels = widget.repository
      .loadAll();

  void _open(List<LevelDefinition> levels, int index, {bool replace = false}) {
    final hasNext = index + 1 < levels.length;
    final route = MaterialPageRoute<void>(
      builder: (_) => GameScreen(
        level: levels[index],
        onNext: hasNext ? () => _open(levels, index + 1, replace: true) : null,
      ),
    );
    final navigator = Navigator.of(context);
    replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.cityIstanbul)),
      body: FutureBuilder<List<LevelDefinition>>(
        future: _levels,
        builder: (context, snapshot) {
          final levels = snapshot.data;
          if (snapshot.hasError) {
            return const Center(
              child: Icon(Icons.error_outline, color: AppColors.accentRed),
            );
          }
          if (levels == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => ListTile(
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(l.levelTitle(levels[i].number)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(levels, i),
            ),
          );
        },
      ),
    );
  }
}
