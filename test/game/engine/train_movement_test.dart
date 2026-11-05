import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/board_state.dart';
import 'package:swipeout_last_train/game/domain/cell.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/domain/move_result.dart';
import 'package:swipeout_last_train/game/engine/game_rules.dart';

import '../../support/level_builders.dart';

BoardState _applyAll(LevelDefinition level, List<Move> moves) {
  final rules = GameRules(level);
  var state = level.initialState;
  for (final move in moves) {
    final result = rules.apply(state, move);
    if (result is! MoveApplied) fail('$move rejected: $result');
    state = result.state;
  }
  return state;
}

BoardState _withTrainAt(BoardState state, String id, GridPos pos) =>
    state.withTrain(state.trainById(id)!.copyWith(position: pos));

void main() {
  const east = TrainMove('r1', Direction.east);

  test('moves one cell along matching ports', () {
    final level = lineLevel();
    final result = GameRules(level).apply(level.initialState, east);

    expect(result, isA<MoveApplied>());
    final state = (result as MoveApplied).state;
    expect(state.trainById('r1')!.position, const GridPos(1, 2));
    expect(result.deliveredTrainId, isNull);
  });

  test('rejects a direction with no exit port', () {
    final level = lineLevel();
    final result = GameRules(
      level,
    ).apply(level.initialState, const TrainMove('r1', Direction.north));

    expect(result, const MoveRejected(RejectReason.noExit));
  });

  test('rejects a target without the opposite port', () {
    final base = lineLevel();
    final level = buildLevel(
      cells: {...base.cells, const GridPos(1, 2): track('NS')},
      trains: base.initialTrains,
    );

    expect(
      GameRules(level).apply(level.initialState, east),
      const MoveRejected(RejectReason.noEntry),
    );
  });

  test('rejects an occupied target', () {
    final level = queueLevel();

    expect(
      GameRules(level).apply(level.initialState, east),
      const MoveRejected(RejectReason.occupied),
    );
  });

  test('rejects a wrong-colour station and keeps state', () {
    final level = switchLevel();
    final before = _applyAll(level, const [
      east,
      east,
      TrainMove('r1', Direction.south),
    ]);

    final result = GameRules(
      level,
    ).apply(before, const TrainMove('r1', Direction.south));

    expect(result, const MoveRejected(RejectReason.wrongStation));
    expect(before.trainById('r1')!.position, const GridPos(2, 3));
  });

  test('delivers on the matching station and vacates the cell', () {
    final level = lineLevel();
    final beforeLast = _applyAll(level, const [east, east, east]);

    final result = GameRules(level).apply(beforeLast, east) as MoveApplied;

    expect(result.deliveredTrainId, 'r1');
    expect(result.state.trainById('r1')!.delivered, isTrue);
    expect(result.state.trainAt(const GridPos(4, 2)), isNull);
  });

  test('a delivered train cannot move', () {
    final level = lineLevel();
    final solved = _applyAll(level, const [east, east, east, east]);

    expect(
      GameRules(level).apply(solved, const TrainMove('r1', Direction.west)),
      const MoveRejected(RejectReason.trainDelivered),
    );
  });

  test('unknown train id is rejected', () {
    final level = lineLevel();

    expect(
      GameRules(
        level,
      ).apply(level.initialState, const TrainMove('x9', Direction.east)),
      const MoveRejected(RejectReason.unknownTrain),
    );
  });

  test('cannot enter a switch through its inactive branch', () {
    final level = switchLevel();
    final state = _withTrainAt(
      level.initialState,
      'r1',
      const GridPos(2, 3),
    ).withSwitch(const GridPos(2, 2), SwitchBranch.a);

    expect(
      GameRules(level).apply(state, const TrainMove('r1', Direction.north)),
      const MoveRejected(RejectReason.noEntry),
    );
  });

  test('a train on a switch leaves only through active ports', () {
    final level = switchLevel();
    final state = _withTrainAt(
      level.initialState,
      'r1',
      const GridPos(2, 2),
    ).withSwitch(const GridPos(2, 2), SwitchBranch.a);
    final rules = GameRules(level);

    expect(
      rules.apply(state, const TrainMove('r1', Direction.south)),
      const MoveRejected(RejectReason.noExit),
    );
    expect(rules.apply(state, east), isA<MoveApplied>());
  });
}
