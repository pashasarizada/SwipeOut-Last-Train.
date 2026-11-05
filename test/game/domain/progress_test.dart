import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_result.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';

void main() {
  const win = LevelResult(
    levelId: 'ANK-01',
    pulses: 3,
    rating: StarRating.silver,
  );

  test('a better result replaces the record, a worse one does not', () {
    final p = const Progress().withResult(win);
    expect(p.records['ANK-01']!.bestPulses, 3);

    final better = p.withResult(
      const LevelResult(levelId: 'ANK-01', pulses: 2, rating: StarRating.gold),
    );
    expect(better.records['ANK-01']!.bestPulses, 2);
    expect(better.records['ANK-01']!.rating, StarRating.gold);

    final worse = better.withResult(win);
    expect(worse.records['ANK-01']!.bestPulses, 2);
  });

  test('solved counts only the given level ids', () {
    final p = const Progress()
        .withResult(win)
        .withResult(
          const LevelResult(levelId: 'OLD-99', pulses: 1, rating: null),
        );
    expect(p.isSolved('ANK-01'), isTrue);
    expect(p.solvedIn(['ANK-01', 'ANK-02']), 1);
  });

  test('a stamp date is kept from the first time it was earned', () {
    final first = DateTime(2026, 11, 5);
    final p = const Progress()
        .withStamp(CityId.ankara, first)
        .withStamp(CityId.ankara, DateTime(2027));
    expect(p.stampDates[CityId.ankara], first);
  });

  test('the saved run can be set and cleared', () {
    final p = const Progress().withRun(
      const SavedRun(levelId: 'ANK-02', actions: [ToggleSwitch('B')]),
    );
    expect(p.run!.actions, const [ToggleSwitch('B')]);
    expect(p.withRun(null).run, isNull);
  });
}
