// Level authoring helper: validates every indexed level and prints its
// optimal solution. Exits with code 1 if any level has an issue.
//
//   dart run tool/solve_levels.dart
import 'dart:convert';
import 'dart:io';

import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/engine/level_solver.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';

Map<String, Object?> _read(String file) =>
    jsonDecode(File('${LevelIndex.assetDir}/$file').readAsStringSync())
        as Map<String, Object?>;

String _describe(Move move) => switch (move) {
  TrainMove(:final trainId, :final direction) => '$trainId:${direction.code}',
  SwitchToggle(:final position) => 'T($position)',
};

void main() {
  final index = LevelIndex.fromJson(_read(LevelIndex.fileName));
  var failed = false;

  for (final file in index.files) {
    final level = const LevelJsonCodec().decode(_read(file));
    final issues = const LevelValidator().validate(level);
    final outcome = const LevelSolver().solve(level);
    final solution = outcome is Solved
        ? 'optimal=${outcome.moves.length}  solution=${outcome.moves.map(_describe).join(' ')}'
        : outcome.runtimeType.toString();

    stdout.writeln('$file  issues=${issues.length}  $solution');
    for (final issue in issues) {
      stdout.writeln('    - $issue');
    }
    failed = failed || issues.isNotEmpty;
  }
  exitCode = failed ? 1 : 0;
}
