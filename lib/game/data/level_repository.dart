import '../domain/city.dart';
import '../domain/level_definition.dart';

/// Source of playable levels. Screens depend on this, not on assets (DIP).
abstract interface class LevelRepository {
  /// The city's levels in play order; empty when none are authored yet.
  Future<List<LevelDefinition>> loadCity(CityId city);
}
