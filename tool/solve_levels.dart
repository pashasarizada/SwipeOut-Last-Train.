// Level authoring helper: validates every indexed level and prints its
// optimum and recorded solution. Exits with code 1 if any level has issues.
//
//   dart run tool/solve_levels.dart
import 'dart:convert';
import 'dart:io';

import 'package:swipeout_last_train/game/data/action_codec.dart';
import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';

Object? _read(String file) =>
    jsonDecode(File('${LevelIndex.assetDir}/$file').readAsStringSync());

void main() {
  final index = LevelIndex.fromJson(_read(LevelIndex.fileName));
  var failed = false;

  for (final city in CityId.values) {
    for (final file in index.filesFor(city)) {
      final level = const LevelJsonCodec().decode(
        _read(file)! as Map<String, Object?>,
      );
      final result = const LevelValidator().validate(level);
      final optimum = result.optimum?.toString() ?? result.solve.runtimeType;
      final solution = level.solution.map(ActionCodec.encode).join(' ');
      stdout.writeln(
        '${level.id}  issues=${result.issues.length}  optimal=$optimum  '
        'par=${level.parPulses}  max=${level.maxPulses}  solution=$solution',
      );
      for (final issue in result.issues) {
        stdout.writeln('    - $issue');
      }
      failed = failed || !result.isValid;
    }
  }
  exitCode = failed ? 1 : 0;
}
