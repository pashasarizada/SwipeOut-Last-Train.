import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/game_state.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/engine/hint_finder.dart';
import 'package:swipeout_last_train/game/engine/pulse_engine.dart';

import '../../support/graph_builders.dart';

GameState _after(LevelDefinition level, List<ControlAction?> actions) {
  final engine = PulseEngine(level);
  var state = level.initialState;
  for (final a in actions) {
    state = (engine.simulatePulse(state, a) as PulseApplied).state;
  }
  return state;
}

void main() {
  test('on the recorded solution, the hint is its next step', () {
    final level = ank02();
    expect(
      HintFinder(level).next(level.initialState, const []),
      HintAction(level.solution.first),
    );
  });

  test('off the recorded solution, the solver finds the next step', () {
    final level = ank01();
    const history = [ToggleSwitch('B')];
    // B already points home: the train only has to roll on.
    expect(
      HintFinder(level).next(_after(level, history), history),
      const HintAction(null),
    );
  });

  test('a run that can no longer be saved points at undo', () {
    final level = jamLevel();
    final jammed = _after(level, const [null]);
    expect(HintFinder(level).next(jammed, const [null]), const HintUndo());
  });

  for (final level in [ank01(), ank02(), wrongWayLevel()]) {
    test('${level.id}: following hints always solves the level', () {
      final engine = PulseEngine(level);
      final finder = HintFinder(level);
      var state = level.initialState;
      final history = <ControlAction?>[];
      while (!engine.isSolved(state)) {
        final hint = finder.next(state, history);
        expect(hint, isA<HintAction>(), reason: 'at pulse ${state.pulse}');
        final action = (hint as HintAction).action;
        state = (engine.simulatePulse(state, action) as PulseApplied).state;
        history.add(action);
      }
      expect(state.pulse, lessThanOrEqualTo(level.maxPulses));
    });
  }
}
