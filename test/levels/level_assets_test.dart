import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';

Object? _read(String file) =>
    jsonDecode(File('${LevelIndex.assetDir}/$file').readAsStringSync());

void main() {
  final index = LevelIndex.fromJson(_read(LevelIndex.fileName));
  final levels = <LevelDefinition>[
    for (final city in CityId.values)
      for (final file in index.filesFor(city))
        const LevelJsonCodec().decode(_read(file)! as Map<String, Object?>),
  ];

  test('the index lists all five cities in order', () {
    expect(index.cities, CityId.values);
  });

  for (final level in levels) {
    test('${level.id} passes validation', () {
      final result = const LevelValidator().validate(level);
      expect(result.issues, isEmpty);
    });
  }

  test('ids are unique and follow the city prefix', () {
    expect(levels.map((l) => l.id).toSet(), hasLength(levels.length));
    for (final level in levels) {
      expect(level.id, startsWith(LevelIndex.prefixOf(level.city)));
    }
  });

  test('Ankara starts with the two tutorial levels', () {
    expect(levels.take(2).map((l) => (l.id, l.parPulses, l.tutorial)), [
      ('ANK-01', 2, true),
      ('ANK-02', 3, true),
    ]);
  });
}
