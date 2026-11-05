import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';

const _dir = 'assets/levels';

Map<String, Object?> _readJson(String file) =>
    jsonDecode(File('$_dir/$file').readAsStringSync()) as Map<String, Object?>;

void main() {
  final files = LevelIndex.fromJson(_readJson('index.json')).files;
  final levels = <LevelDefinition>[
    for (final file in files) const LevelJsonCodec().decode(_readJson(file)),
  ];

  test('index lists at least the three tutorial levels', () {
    expect(files.length, greaterThanOrEqualTo(3));
  });

  for (final (i, level) in levels.indexed) {
    test('${files[i]} passes validation', () {
      expect(const LevelValidator().validate(level), isEmpty);
    });
  }

  test('level numbers run 1..n and ids are unique', () {
    expect(levels.map((l) => l.number), [
      for (var i = 1; i <= levels.length; i++) i,
    ]);
    expect(levels.map((l) => l.id).toSet(), hasLength(levels.length));
  });

  test('tutorial optimums are 4, 5 and 8', () {
    expect(levels.take(3).map((l) => l.optimalMoves), [4, 5, 8]);
  });
}
