import 'city.dart';
import 'progress.dart';

/// A city's stamp needs this many solved levels (docs/GAME_DESIGN_V2.md §1).
const int kLevelsPerCity = 6;

final class CityStamp {
  const CityStamp({
    required this.city,
    required this.solved,
    required this.earned,
    this.earnedOn,
  });

  final CityId city;
  final int solved;
  final bool earned;
  final DateTime? earnedOn;

  int get total => kLevelsPerCity;

  /// The final city's stamp is gold.
  bool get gold => city == CityId.moscow;
}

/// The Metro Passport, derived from progress: cosmetic and offline.
final class Passport {
  const Passport._(this.stamps);

  factory Passport.from(
    Progress progress,
    Map<CityId, List<String>> levelIds,
  ) => Passport._([
    for (final city in CityId.values)
      CityStamp(
        city: city,
        solved: progress.solvedIn(levelIds[city] ?? const []),
        earned: _complete(progress, levelIds[city] ?? const []),
        earnedOn: progress.stampDates[city],
      ),
  ]);

  final List<CityStamp> stamps;

  CityStamp stampFor(CityId city) => stamps.firstWhere((s) => s.city == city);

  /// All five cities stamped.
  bool get isNightDispatcher => stamps.every((s) => s.earned);

  /// Records today's date for cities that just became complete; returns the
  /// updated progress and those cities (to play the stamp scene).
  static (Progress, List<CityId>) recordStamps(
    Progress progress,
    Map<CityId, List<String>> levelIds,
    DateTime now,
  ) {
    final fresh = [
      for (final city in CityId.values)
        if (!progress.stampDates.containsKey(city) &&
            _complete(progress, levelIds[city] ?? const []))
          city,
    ];
    return (fresh.fold(progress, (p, city) => p.withStamp(city, now)), fresh);
  }

  /// A city counts only once it has its full set of levels, all solved.
  static bool _complete(Progress progress, List<String> ids) =>
      ids.length >= kLevelsPerCity && progress.solvedIn(ids) == ids.length;
}
