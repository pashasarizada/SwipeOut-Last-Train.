import 'dart:convert';
import 'dart:io';

import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';

Object? _read(String file) =>
    jsonDecode(File('${LevelIndex.assetDir}/$file').readAsStringSync());

/// Every shipped level, read straight from `assets/levels`.
List<LevelDefinition> allLevels() {
  final index = LevelIndex.fromJson(_read(LevelIndex.fileName));
  return [
    for (final city in CityId.values)
      for (final file in index.filesFor(city))
        const LevelJsonCodec().decode(_read(file)! as Map<String, Object?>),
  ];
}

/// Board squares of a large phone, the iPhone SE and the original SE.
const List<double> boardSides = [360, 300, 260];
