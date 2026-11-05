import '../domain/city.dart';
import '../domain/level_definition.dart';

/// Source of playable levels. Screens depend on this, not on assets (DIP).
abstract interface class LevelRepository {
  /// The city's levels in play order; empty when none are authored yet.
  Future<List<LevelDefinition>> loadCity(CityId city);
}

/// Every city's levels, loaded once at start-up.
Future<Map<CityId, List<LevelDefinition>>> loadCatalog(
  LevelRepository repository,
) async => {
  for (final city in CityId.values) city: await repository.loadCity(city),
};
