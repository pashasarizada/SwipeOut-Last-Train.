import 'package:flutter/foundation.dart';

import '../../data/progress_repository.dart';
import '../../domain/city.dart';
import '../../domain/control_action.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../../domain/passport.dart';
import '../../domain/progress.dart';

/// Where "Continue" leads: a level and, if half-played, its saved controls.
typedef ContinueTarget = ({
  LevelDefinition level,
  List<ControlAction?> actions,
});

/// The level catalogue plus the player's progress, shared by every screen.
/// Persists through [ProgressRepository] after each change.
final class ProgressStore extends ChangeNotifier {
  ProgressStore({
    required Map<CityId, List<LevelDefinition>> catalog,
    required ProgressRepository repository,
    required Progress progress,
    DateTime Function()? clock,
  }) : catalog = Map.unmodifiable(catalog),
       _repository = repository,
       _progress = progress,
       _clock = clock ?? DateTime.now;

  final Map<CityId, List<LevelDefinition>> catalog;
  final ProgressRepository _repository;
  final DateTime Function() _clock;
  Progress _progress;

  Progress get progress => _progress;

  Map<CityId, List<String>> get levelIds => {
    for (final MapEntry(:key, :value) in catalog.entries)
      key: [for (final l in value) l.id],
  };

  Passport get passport => Passport.from(_progress, levelIds);

  List<LevelDefinition> levelsOf(CityId city) => catalog[city] ?? const [];

  LevelDefinition? levelById(String id) {
    for (final levels in catalog.values) {
      for (final level in levels) {
        if (level.id == id) return level;
      }
    }
    return null;
  }

  /// A city's first level is always open; each next one opens once the
  /// previous is solved (docs/GAME_DESIGN_V2.md §2).
  bool isUnlocked(LevelDefinition level) {
    final levels = levelsOf(level.city);
    final index = levels.indexWhere((l) => l.id == level.id);
    return index <= 0 || _progress.isSolved(levels[index - 1].id);
  }

  /// The saved half-played level, else the first unsolved open level.
  ContinueTarget? continueTarget() {
    final run = _progress.run;
    final saved = run == null ? null : levelById(run.levelId);
    if (run != null && saved != null) {
      return (level: saved, actions: run.actions);
    }
    for (final city in CityId.values) {
      for (final level in levelsOf(city)) {
        if (!_progress.isSolved(level.id) && isUnlocked(level)) {
          return (level: level, actions: const []);
        }
      }
    }
    return null;
  }

  /// Saves a half-played level; an empty history clears it.
  Future<void> saveRun(String levelId, List<ControlAction?> actions) => _update(
    _progress.withRun(
      actions.isEmpty ? null : SavedRun(levelId: levelId, actions: actions),
    ),
  );

  /// Records a win and returns the cities whose stamp it just earned.
  Future<List<CityId>> recordWin(LevelResult result) async {
    final solved = _progress.withResult(result).withRun(null);
    final (stamped, fresh) = Passport.recordStamps(
      solved,
      levelIds,
      _clock().toUtc(),
    );
    await _update(stamped);
    return fresh;
  }

  /// The new progress is live at once; a failed disk write is reported
  /// but never breaks the game — the next change saves everything again.
  Future<void> _update(Progress next) async {
    _progress = next;
    notifyListeners();
    try {
      await _repository.save(next);
    } on Object catch (error) {
      debugPrint('Progress not saved: $error');
    }
  }
}
