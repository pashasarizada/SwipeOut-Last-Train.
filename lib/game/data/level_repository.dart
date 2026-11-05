import '../domain/level_definition.dart';

/// Source of playable levels. UI depends on this, not on assets (DIP).
abstract interface class LevelRepository {
  /// All levels, ordered by [LevelDefinition.number].
  Future<List<LevelDefinition>> loadAll();
}
