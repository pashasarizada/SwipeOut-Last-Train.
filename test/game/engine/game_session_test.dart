import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/engine/game_session.dart';
import 'package:swipeout_last_train/game/engine/undo_history.dart';

import '../../support/level_builders.dart';

void main() {
  const east = TrainMove('r1', Direction.east);
  const north = TrainMove('r1', Direction.north);

  test('valid moves count, rejected moves do not', () {
    final session = GameSession(lineLevel());

    session.play(east);
    expect(session.moveCount, 1);

    session.play(north);
    expect(session.moveCount, 1);
  });

  test('undo restores the exact previous state', () {
    final session = GameSession(switchLevel());
    final before = session.state;

    session.play(const SwitchToggle(GridPos(2, 2)));
    expect(session.state, isNot(before));

    expect(session.undo(), isTrue);
    expect(session.state, before);
    expect(session.moveCount, 0);
  });

  test('undo brings a delivered train back', () {
    final session = GameSession(lineLevel());
    for (var i = 0; i < 4; i++) {
      session.play(east);
    }
    expect(session.isSolved, isTrue);

    session.undo();

    final train = session.state.trainById('r1')!;
    expect(train.delivered, isFalse);
    expect(train.position, const GridPos(3, 2));
    expect(session.isSolved, isFalse);
  });

  test('undo on a fresh session returns false', () {
    final session = GameSession(lineLevel());

    expect(session.canUndo, isFalse);
    expect(session.undo(), isFalse);
  });

  test('restart resets state, count and history', () {
    final level = lineLevel();
    final session = GameSession(level)
      ..play(east)
      ..play(east);

    session.restart();

    expect(session.state, level.initialState);
    expect(session.moveCount, 0);
    expect(session.canUndo, isFalse);
  });

  test('UndoHistory is LIFO', () {
    final history = UndoHistory<int>()
      ..push(1)
      ..push(2);

    expect(history.length, 2);
    expect(history.pop(), 2);
    expect(history.pop(), 1);
    expect(history.pop(), isNull);
    expect(history.canUndo, isFalse);
  });
}
