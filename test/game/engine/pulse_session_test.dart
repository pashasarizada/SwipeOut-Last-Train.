import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/engine/game_session.dart';
import 'package:swipeout_last_train/game/engine/undo_history.dart';

import '../../support/graph_builders.dart';

void main() {
  test('a successful pulse is undoable and restores switches too', () {
    final session = GameSession(ank02());
    final before = session.state;

    session.pulse(const ToggleSwitch('B'));
    expect(session.state.switches['B'], SwitchBranch.a);
    expect(session.pulses, 1);

    expect(session.undo(), isTrue);
    expect(session.state, before);
    expect(session.pulses, 0);
  });

  test('a failed pulse does not enter history', () {
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
    final session = GameSession(level);

    expect(session.pulse(null), isA<PulseFailed>());
    expect(session.canUndo, isFalse);
    expect(session.pulses, 0);
  });

  test('running out of pulses is a loss and undo recovers', () {
    final session = GameSession(ank01());
    for (var i = 0; i < ank01().maxPulses; i++) {
      session.pulse(null);
    }
    expect(session.isLost, isTrue);
    expect(session.pulse(null), isA<PulseFailed>());

    session.undo();
    expect(session.isLost, isFalse);
  });

  test('winning on the last allowed pulse counts as solved', () {
    final base = ank01();
    final tight = buildLevel(
      nodes: base.nodes.values.toList(),
      edges: base.edges.keys.toList(),
      switches: base.switches.values.toList(),
      initialSwitches: base.initialSwitches,
      trains: base.trains,
      maxPulses: 2,
      parPulses: 2,
    );
    final session = GameSession(tight)
      ..pulse(null)
      ..pulse(const ToggleSwitch('B'));

    expect(session.pulses, tight.maxPulses);
    expect(session.isSolved, isTrue);
    expect(session.isLost, isFalse);
  });

  test('restart returns to the initial state', () {
    final level = ank02();
    final session = GameSession(level)
      ..pulse(const ToggleSwitch('B'))
      ..pulse(null);

    session.restart();

    expect(session.state, level.initialState);
    expect(session.canUndo, isFalse);
  });

  test('UndoHistory is LIFO', () {
    final history = UndoHistory<int>()
      ..push(1)
      ..push(2);
    expect(history.pop(), 2);
    expect(history.pop(), 1);
    expect(history.pop(), isNull);
  });
}
