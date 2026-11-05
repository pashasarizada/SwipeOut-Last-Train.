import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeout_last_train/game/data/prefs_progress_repository.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_result.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';

Future<PrefsProgressRepository> _repo([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return PrefsProgressRepository(await SharedPreferences.getInstance());
}

void main() {
  test('progress survives a save and a fresh load', () async {
    final repo = await _repo();
    final progress = const Progress()
        .withResult(
          const LevelResult(
            levelId: 'ANK-01',
            pulses: 2,
            rating: StarRating.gold,
          ),
        )
        .withResult(
          const LevelResult(levelId: 'ANK-02', pulses: 4, rating: null),
        )
        .withRun(
          const SavedRun(levelId: 'ANK-02', actions: [ToggleSwitch('B'), null]),
        )
        .withStamp(CityId.ankara, DateTime.utc(2026, 11, 5));

    await repo.save(progress);
    final loaded = await (await PrefsProgressRepository.open()).load();

    expect(loaded.records['ANK-01']!.rating, StarRating.gold);
    expect(loaded.records['ANK-02']!.rating, isNull);
    expect(loaded.records['ANK-02']!.bestPulses, 4);
    expect(loaded.run!.levelId, 'ANK-02');
    expect(loaded.run!.actions, const [ToggleSwitch('B'), null]);
    expect(loaded.stampDates[CityId.ankara], DateTime.utc(2026, 11, 5));
  });

  test('nothing saved yet is empty progress', () async {
    final loaded = await (await _repo()).load();
    expect(loaded.records, isEmpty);
    expect(loaded.run, isNull);
  });

  test('corrupt data is ignored instead of crashing', () async {
    for (final bad in [
      '{not json',
      '[]',
      '{"records": 5}',
      '{"records": {"A": {"bestPulses": "x"}}}',
    ]) {
      final loaded = await (await _repo({
        PrefsProgressRepository.key: bad,
      })).load();
      expect(loaded.records, isEmpty, reason: bad);
    }
  });
}
