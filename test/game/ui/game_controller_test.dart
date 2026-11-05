import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/board_state.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/domain/move_result.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';
import 'package:swipeout_last_train/game/engine/level_solver.dart';
import 'package:swipeout_last_train/game/ui/game/game_controller.dart';
import 'package:swipeout_last_train/game/ui/game/game_event.dart';
import 'package:swipeout_last_train/game/ui/game/hint_runner.dart';

import '../../support/level_builders.dart';

const _lock = Duration(milliseconds: 180);

Future<SolverOutcome> _noHint(LevelDefinition _, BoardState _) async =>
    const SearchLimitReached();

/// Runs [body] in fake time with a controller and a list of emitted events.
void _withController(
  LevelDefinition level,
  void Function(FakeAsync async, GameController c, List<GameEvent> events)
  body, {
  HintRunner hintRunner = _noHint,
}) {
  fakeAsync((async) {
    final controller = GameController(level: level, hintRunner: hintRunner);
    final events = <GameEvent>[];
    controller.events.listen(events.add);
    body(async, controller, events);
    async.flushMicrotasks();
    controller.dispose();
  });
}

void main() {
  test('a single remaining train is selected automatically', () {
    _withController(lineLevel(), (_, c, __) {
      expect(c.selectedTrainId, 'r1');
    });
  });

  test('with two trains nothing is preselected and swipe asks for a train', () {
    _withController(queueLevel(), (async, c, events) {
      expect(c.selectedTrainId, isNull);

      c.swipe(Direction.east);
      async.flushMicrotasks();

      expect(events.single, isA<SelectTrainFirst>());
      expect(c.moveCount, 0);
    });
  });

  test('tapping a train selects it', () {
    _withController(queueLevel(), (_, c, __) {
      c.tapCell(const GridPos(0, 2));
      expect(c.selectedTrainId, 'r1');

      c.tapCell(const GridPos(1, 2));
      expect(c.selectedTrainId, 'b1');
    });
  });

  test('tapping a switch toggles it, tapping empty cells does nothing', () {
    _withController(switchLevel(), (_, c, __) {
      c.tapCell(const GridPos(4, 4));
      c.tapCell(const GridPos(4, 2));
      expect(c.moveCount, 0);

      c.tapCell(const GridPos(2, 2));
      expect(c.moveCount, 1);
    });
  });

  test('a blocked move emits MoveBlocked and is not counted', () {
    _withController(queueLevel(), (async, c, events) {
      c.tapCell(const GridPos(0, 2));
      c.swipe(Direction.east);
      async.flushMicrotasks();

      expect(
        events.single,
        isA<MoveBlocked>().having(
          (e) => e.reason,
          'reason',
          RejectReason.occupied,
        ),
      );
      expect(c.moveCount, 0);
    });
  });

  test('input is locked while a move animates', () {
    _withController(lineLevel(), (async, c, _) {
      c.swipe(Direction.east);
      c.swipe(Direction.east);
      expect(c.moveCount, 1);
      expect(c.isBusy, isTrue);

      async.elapse(_lock);
      expect(c.isBusy, isFalse);

      c.swipe(Direction.east);
      expect(c.moveCount, 2);
    });
  });

  test('a switch toggle moves no train, so input stays unlocked', () {
    _withController(switchLevel(), (_, c, __) {
      c.tapCell(const GridPos(2, 2));

      expect(c.isBusy, isFalse);
      c.swipe(Direction.east);
      expect(c.moveCount, 2);
    });
  });

  test('finishing the level emits delivery and completion with stars', () {
    _withController(lineLevel(), (async, c, events) {
      for (var i = 0; i < 4; i++) {
        c.swipe(Direction.east);
        async.elapse(_lock);
      }

      expect(c.isSolved, isTrue);
      expect(events.whereType<TrainDelivered>().single.trainId, 'r1');
      final result = events.whereType<LevelCompleted>().single.result;
      expect(result.moves, 4);
      expect(result.rating, StarRating.gold);
      expect(result.levelId, 'line');
    });
  });

  test('undo and restart reverse moves and keep the auto-selection', () {
    _withController(lineLevel(), (async, c, _) {
      c.swipe(Direction.east);
      async.elapse(_lock);

      c.undo();
      expect(c.moveCount, 0);
      async.elapse(_lock);

      c.swipe(Direction.east);
      async.elapse(_lock);
      c.restart();
      expect(c.state, lineLevel().initialState);
      expect(c.selectedTrainId, 'r1');
    });
  });

  test('a hint exposes the next optimal move until the board changes', () {
    _withController(
      lineLevel(),
      hintRunner: (_, _) async =>
          const Solved([TrainMove('r1', Direction.east)]),
      (async, c, _) {
        c.requestHint();
        async.flushMicrotasks();
        expect(c.hint, const TrainMove('r1', Direction.east));

        c.swipe(Direction.east);
        expect(c.hint, isNull);
      },
    );
  });

  test('no hint emits HintUnavailable', () {
    _withController(lineLevel(), (async, c, events) {
      c.requestHint();
      async.flushMicrotasks();

      expect(c.hint, isNull);
      expect(events.single, isA<HintUnavailable>());
    });
  });
}
