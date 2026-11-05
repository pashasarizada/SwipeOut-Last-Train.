import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_result.dart';
import 'package:swipeout_last_train/game/domain/passport.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';

List<String> _six(String prefix) => [
  for (var i = 1; i <= 6; i++) '$prefix-0$i',
];

Progress _solve(Progress p, Iterable<String> ids) => ids.fold(
  p,
  (acc, id) =>
      acc.withResult(LevelResult(levelId: id, pulses: 1, rating: null)),
);

final _allSix = {for (final c in CityId.values) c: _six(c.name)};

void main() {
  test('finishing all six levels of a city earns its stamp', () {
    final passport = Passport.from(
      _solve(const Progress(), _six('ankara')),
      _allSix,
    );
    final ankara = passport.stampFor(CityId.ankara);
    expect(ankara.earned, isTrue);
    expect(ankara.gold, isFalse);
    expect(passport.stampFor(CityId.baku).earned, isFalse);
  });

  test("Moscow's stamp is gold", () {
    final passport = Passport.from(
      _solve(const Progress(), _six('moscow')),
      _allSix,
    );
    expect(passport.stampFor(CityId.moscow).earned, isTrue);
    expect(passport.stampFor(CityId.moscow).gold, isTrue);
  });

  test(
    'a city with fewer than six authored levels cannot be stamped early',
    () {
      final ids = {
        CityId.ankara: ['ANK-01', 'ANK-02'],
      };
      final passport = Passport.from(
        _solve(const Progress(), ids[CityId.ankara]!),
        ids,
      );
      final ankara = passport.stampFor(CityId.ankara);
      expect(ankara.earned, isFalse);
      expect(ankara.solved, 2);
      expect(ankara.total, kLevelsPerCity);
    },
  );

  test('five stamps make a Night Dispatcher', () {
    final all = _solve(const Progress(), _allSix.values.expand((ids) => ids));
    expect(Passport.from(all, _allSix).isNightDispatcher, isTrue);
    expect(
      Passport.from(
        _solve(const Progress(), _six('ankara')),
        _allSix,
      ).isNightDispatcher,
      isFalse,
    );
  });

  test('newly completed cities get their stamp date once', () {
    final day = DateTime.utc(2026, 11, 5);
    final p = _solve(const Progress(), _six('paris'));

    final (stamped, fresh) = Passport.recordStamps(p, _allSix, day);
    expect(fresh, [CityId.paris]);
    expect(stamped.stampDates[CityId.paris], day);

    final (_, again) = Passport.recordStamps(
      stamped,
      _allSix,
      DateTime.utc(2027),
    );
    expect(again, isEmpty);
    expect(
      Passport.from(stamped, _allSix).stampFor(CityId.paris).earnedOn,
      day,
    );
  });
}
