import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/board_state.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/domain/move_result.dart';
import 'package:swipeout_last_train/game/domain/train_color.dart';
import 'package:swipeout_last_train/game/engine/game_rules.dart';
import 'package:swipeout_last_train/game/engine/level_solver.dart';

import '../../support/level_builders.dart';

BoardState _replay(
  LevelDefinition level,
  List<Move> moves, [
  BoardState? from,
]) {
  final rules = GameRules(level);
  var state = from ?? level.initialState;
  for (final move in moves) {
    final result = rules.apply(state, move);
    if (result is! MoveApplied) fail('$move rejected during replay');
    state = result.state;
  }
  return state;
}

List<Move> _solve(LevelDefinition level, {BoardState? from}) =>
    (const LevelSolver().solve(level, from: from) as Solved).moves;

void main() {
  const east = TrainMove('r1', Direction.east);

  test('line level is solved by four east moves', () {
    expect(_solve(lineLevel()), List.filled(4, east));
  });

  test('switch level needs five moves and the solution replays', () {
    final level = switchLevel();
    final moves = _solve(level);

    expect(moves, hasLength(5));
    expect(GameRules(level).isSolved(_replay(level, moves)), isTrue);
  });

  test('queue level needs eight moves', () {
    final level = queueLevel();
    final moves = _solve(level);

    expect(moves, hasLength(8));
    expect(GameRules(level).isSolved(_replay(level, moves)), isTrue);
  });

  test('solving is deterministic', () {
    expect(_solve(queueLevel()), _solve(queueLevel()));
  });

  test('a station without connecting track is unsolvable', () {
    final level = buildLevel(
      cells: {
        const GridPos(0, 2): track('E'),
        const GridPos(1, 2): track('W'),
        const GridPos(4, 2): station(TrainColor.red, 'W'),
      },
      trains: [train('r1', TrainColor.red, 0, 2)],
    );

    expect(const LevelSolver().solve(level), isA<Unsolvable>());
  });

  test('search stops at the state limit', () {
    expect(
      const LevelSolver(maxStates: 3).solve(queueLevel()),
      isA<SearchLimitReached>(),
    );
  });

  test('solves from a mid-game state', () {
    final level = lineLevel();
    final mid = _replay(level, const [east, east]);

    expect(_solve(level, from: mid), hasLength(2));
  });

  test('an already solved state needs no moves', () {
    final level = lineLevel();
    final solved = _replay(level, List.filled(4, east));

    expect(_solve(level, from: solved), isEmpty);
  });
}
