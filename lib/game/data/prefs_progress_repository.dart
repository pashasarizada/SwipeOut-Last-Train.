import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/city.dart';
import '../domain/progress.dart';
import '../domain/star_rating.dart';
import 'action_codec.dart';
import 'json_reader.dart';
import 'progress_repository.dart';

/// Progress as one JSON document in `shared_preferences`. Corrupt or
/// unexpected data loads as empty progress rather than crashing.
final class PrefsProgressRepository implements ProgressRepository {
  PrefsProgressRepository(this.prefs);

  static const String key = 'progress.v1';

  final SharedPreferences prefs;

  static Future<PrefsProgressRepository> open() async =>
      PrefsProgressRepository(await SharedPreferences.getInstance());

  @override
  Future<Progress> load() async {
    final raw = prefs.getString(key);
    if (raw == null) return const Progress();
    try {
      return _decode(jsonDecode(raw));
    } on Object {
      return const Progress();
    }
  }

  @override
  Future<void> save(Progress progress) =>
      prefs.setString(key, jsonEncode(_encode(progress)));

  static Map<String, Object?> _encode(Progress p) => {
    'records': {
      for (final r in p.records.values)
        r.levelId: {'bestPulses': r.bestPulses, 'rating': r.rating?.name},
    },
    'run': switch (p.run) {
      null => null,
      final run => {
        'levelId': run.levelId,
        'actions': run.actions.map(ActionCodec.encode).toList(),
      },
    },
    'stamps': {
      for (final MapEntry(:key, :value) in p.stampDates.entries)
        key.name: value.toUtc().toIso8601String(),
    },
  };

  static Progress _decode(Object? json) {
    const r = JsonReader(key);
    final root = r.object(json, 'progress');
    final records = r.object(
      root['records'] ?? const <String, Object?>{},
      'records',
    );
    final run = root['run'] == null ? null : r.object(root['run'], 'run');
    final stamps = r.object(
      root['stamps'] ?? const <String, Object?>{},
      'stamps',
    );
    return Progress(
      records: {
        for (final MapEntry(key: id, :value) in records.entries)
          id: _record(r, id, r.object(value, 'record')),
      },
      run: run == null
          ? null
          : SavedRun(
              levelId: r.field<String>(run, 'levelId'),
              actions: [
                for (final step in r.field<List<Object?>>(run, 'actions'))
                  ActionCodec.decode(
                    step is String ? step : r.fail('bad step'),
                    levelId: key,
                  ),
              ],
            ),
      stampDates: {
        for (final MapEntry(key: city, :value) in stamps.entries)
          r.byName(CityId.values, city, 'city'): DateTime.parse(
            value is String ? value : r.fail('bad date'),
          ),
      },
    );
  }

  static LevelRecord _record(
    JsonReader r,
    String id,
    Map<String, Object?> json,
  ) {
    final rating = r.optional<String>(json, 'rating');
    return LevelRecord(
      levelId: id,
      bestPulses: r.field<int>(json, 'bestPulses'),
      rating: rating == null
          ? null
          : r.byName(StarRating.values, rating, 'rating'),
    );
  }
}
