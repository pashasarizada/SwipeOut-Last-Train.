import 'package:swipeout_last_train/game/data/level_repository.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';

final class FakeLevelRepository implements LevelRepository {
  FakeLevelRepository(this.cities);

  final Map<CityId, List<LevelDefinition>> cities;

  @override
  Future<List<LevelDefinition>> loadCity(CityId city) async =>
      cities[city] ?? const [];
}
