import 'package:swipeout_last_train/game/data/level_repository.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';

final class FakeLevelRepository implements LevelRepository {
  FakeLevelRepository(this.levels);

  final List<LevelDefinition> levels;

  @override
  Future<List<LevelDefinition>> loadAll() async => levels;
}
