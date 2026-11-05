import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/cell.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/domain/move_result.dart';
import 'package:swipeout_last_train/game/engine/game_rules.dart';

import '../../support/level_builders.dart';

void main() {
  const junction = GridPos(2, 2);
  const toggle = SwitchToggle(junction);

  test('toggling a free switch flips its branch', () {
    final level = switchLevel();
    final result =
        GameRules(level).apply(level.initialState, toggle) as MoveApplied;

    expect(result.state.switches[junction], SwitchBranch.a);
  });

  test('a switch with a train on it cannot be toggled', () {
    final level = switchLevel();
    final initial = level.initialState;
    final state = initial.withTrain(
      initial.trainById('r1')!.copyWith(position: junction),
    );

    expect(
      GameRules(level).apply(state, toggle),
      const MoveRejected(RejectReason.switchOccupied),
    );
  });

  test('toggling a non-switch cell is rejected', () {
    final level = switchLevel();

    expect(
      GameRules(
        level,
      ).apply(level.initialState, const SwitchToggle(GridPos(1, 2))),
      const MoveRejected(RejectReason.notASwitch),
    );
  });

  test('legalMoves lists trains first, then switches', () {
    expect(
      GameRules(lineLevel()).legalMoves(lineLevel().initialState).toList(),
      [const TrainMove('r1', Direction.east)],
    );
    expect(
      GameRules(switchLevel()).legalMoves(switchLevel().initialState).toList(),
      [const TrainMove('r1', Direction.east), toggle],
    );
  });

  test('isSolved only when every train is delivered', () {
    final level = lineLevel();
    final rules = GameRules(level);
    var state = level.initialState;
    expect(rules.isSolved(state), isFalse);

    for (var i = 0; i < 4; i++) {
      state =
          (rules.apply(state, const TrainMove('r1', Direction.east))
                  as MoveApplied)
              .state;
    }

    expect(rules.isSolved(state), isTrue);
  });
}
