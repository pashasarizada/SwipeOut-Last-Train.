import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/engine/game_session.dart';
import 'package:swipeout_last_train/game/engine/pulse_solver.dart';

import '../../support/graph_builders.dart';

List<ControlAction?> _plan(LevelDefinition level) =>
    (const PulseSolver().solve(level) as Solved).plan;

bool _replaySolves(LevelDefinition level, List<ControlAction?> plan) {
  final session = GameSession(level);
  for (final action in plan) {
    session.pulse(action);
  }
  return session.isSolved;
}

void main() {
  test('ANK-01 is solved in two pulses, waiting first', () {
    expect(_plan(ank01()), const [null, ToggleSwitch('B')]);
  });

  test('ANK-02 needs three pulses and the plan replays', () {
    final plan = _plan(ank02());
    expect(plan, hasLength(3));
    expect(_replaySolves(ank02(), plan), isTrue);
  });

  test('a deadlock is unsolvable', () {
    final level = buildLevel(
      nodes: [
        node('L', NodeKind.depot),
        node('M', NodeKind.track),
        node('R', NodeKind.depot),
        node('G', NodeKind.goal),
      ],
      edges: const ['LM', 'MR'],
      trains: [trainDef('a', 'L', 'G'), trainDef('b', 'R', 'G')],
    );
    expect(const PulseSolver().solve(level), isA<Unsolvable>());
  });

  test('a solution longer than maxPulses does not count', () {
    final base = ank02();
    final tooTight = buildLevel(
      nodes: base.nodes.values.toList(),
      edges: base.edges.keys.toList(),
      switches: base.switches.values.toList(),
      initialSwitches: base.initialSwitches,
      trains: base.trains,
      maxPulses: 2,
    );
    expect(const PulseSolver().solve(tooTight), isA<Unsolvable>());
  });

  test('search stops at the state limit', () {
    expect(
      const PulseSolver(maxStates: 1).solve(ank02()),
      isA<SearchLimitReached>(),
    );
  });

  test('a solution found while generating is returned even at the limit', () {
    // ANK-01: the solved state is generated at depth 2 among few states.
    expect(const PulseSolver(maxStates: 4).solve(ank01()), isA<Solved>());
  });

  test('solving is deterministic', () {
    expect(_plan(ank02()), _plan(ank02()));
  });

  test('solves from a mid-game state', () {
    final level = ank02();
    final session = GameSession(level)..pulse(const ToggleSwitch('B'));
    final result =
        const PulseSolver().solve(level, from: session.state) as Solved;
    expect(result.plan, hasLength(2));
  });
}
