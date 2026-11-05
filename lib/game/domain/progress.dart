import 'city.dart';
import 'control_action.dart';
import 'level_result.dart';
import 'star_rating.dart';

/// Best result for one level.
final class LevelRecord {
  const LevelRecord({
    required this.levelId,
    required this.bestPulses,
    this.rating,
  });

  final String levelId;
  final int bestPulses;

  /// Null for tutorial levels.
  final StarRating? rating;
}

/// A level left half-played: replaying [actions] restores it exactly.
final class SavedRun {
  const SavedRun({required this.levelId, required this.actions});

  final String levelId;
  final List<ControlAction?> actions;
}

/// Everything the player has achieved, stored on the device only.
final class Progress {
  const Progress({
    this.records = const {},
    this.run,
    this.stampDates = const {},
  });

  final Map<String, LevelRecord> records;
  final SavedRun? run;

  /// When each city's passport stamp was first earned.
  final Map<CityId, DateTime> stampDates;

  bool isSolved(String levelId) => records.containsKey(levelId);

  /// How many of [levelIds] are solved; unknown or old ids never count.
  int solvedIn(Iterable<String> levelIds) => levelIds.where(isSolved).length;

  /// Keeps the result only if it beats the stored one.
  Progress withResult(LevelResult result) {
    final old = records[result.levelId];
    if (old != null && old.bestPulses <= result.pulses) return this;
    return _copy(
      records: {
        ...records,
        result.levelId: LevelRecord(
          levelId: result.levelId,
          bestPulses: result.pulses,
          rating: result.rating,
        ),
      },
    );
  }

  Progress withRun(SavedRun? run) =>
      Progress(records: records, run: run, stampDates: stampDates);

  /// The first date a stamp was earned is never overwritten.
  Progress withStamp(CityId city, DateTime when) => stampDates.containsKey(city)
      ? this
      : _copy(stampDates: {...stampDates, city: when});

  Progress _copy({
    Map<String, LevelRecord>? records,
    Map<CityId, DateTime>? stampDates,
  }) => Progress(
    records: records ?? this.records,
    run: run,
    stampDates: stampDates ?? this.stampDates,
  );
}
