import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/engine/game_session.dart';
import 'package:swipeout_last_train/game/engine/pulse_engine.dart';

import '../../support/graph_builders.dart';

/// L(depot) — M — N — R(depot); goals G and H are off to the side.
LevelDefinition _line() => buildLevel(
  nodes: [
    node('L', NodeKind.depot),
    node('M', NodeKind.track),
    node('N', NodeKind.track),
    node('R', NodeKind.depot),
    node('G', NodeKind.goal),
    node('H', NodeKind.goal),
  ],
  edges: const ['LM', 'MN', 'NR'],
  trains: [trainDef('a', 'L', 'G'), trainDef('b', 'R', 'H')],
);

void main() {
  test('a moving train names the node it will enter', () {
    final level = ank01();
    final f = PulseEngine(level).forecast(level.initialState, null);

    expect(f.ok, isTrue);
    expect(f.moveOf('red_1')!.from, 'A');
    expect(f.moveOf('red_1')!.to, 'B');
    expect(f.delivers, isEmpty);
  });

  test('a train on a closed switch arm or a dead end stays', () {
    final level = ank01();
    final engine = PulseEngine(level);
    // At the terminal D there is no way on.
    final atEnd = stateOf(level, [at('red_1', 'D', 'BD')]);
    expect(engine.forecast(atEnd, null).moveOf('red_1')!.to, isNull);
  });

  test('a red signal holds its train', () {
    final level = buildLevel(
      nodes: [
        node('A', NodeKind.depot),
        node('S', NodeKind.signal),
        node('G', NodeKind.goal),
      ],
      edges: const ['AS', 'SG'],
      initialSignals: {'S': SignalAspect.red},
      trains: [trainDef('a', 'A', 'G')],
    );
    final state = stateOf(level, [at('a', 'S', 'AS')]);
    final engine = PulseEngine(level);

    expect(engine.forecast(state, null).moveOf('a')!.to, isNull);
    expect(
      engine.forecast(state, const ToggleSignal('S')).moveOf('a')!.to,
      'G',
    );
  });

  test('a pulse into the train goal lists the delivery', () {
    final level = ank01();
    final state = stateOf(level, [at('red_1', 'B', 'AB')]);
    final f = PulseEngine(level).forecast(state, const ToggleSwitch('B'));

    expect(f.ok, isTrue);
    expect(f.delivers, {'red_1'});
  });

  test('a collision is reported with its node and trains, moves kept', () {
    final level = _line();
    final state = stateOf(level, [at('a', 'M', 'LM'), at('b', 'R')]);
    // a goes M→N, b goes R→N.
    final f = PulseEngine(level).forecast(state, null);

    expect(f.conflict!.reason, PulseFailure.collision);
    expect(f.conflict!.nodeId, 'N');
    expect(f.conflict!.trainIds, unorderedEquals(['a', 'b']));
    expect(f.moveOf('a')!.to, 'N');
    expect(f.moveOf('b')!.to, 'N');
    expect(f.delivers, isEmpty);
  });

  test('a head-on swap is reported', () {
    final level = _line();
    final state = stateOf(level, [at('a', 'M', 'LM'), at('b', 'N', 'NR')]);
    final f = PulseEngine(level).forecast(state, null);

    expect(f.conflict!.reason, PulseFailure.headOn);
  });

  test('running into a standing train is reported', () {
    final level = _line();
    // b reached the dead end R and stands still; a drives into it.
    final standing = stateOf(level, [at('a', 'N', 'MN'), at('b', 'R', 'NR')]);
    final f = PulseEngine(level).forecast(standing, null);

    expect(f.conflict!.reason, PulseFailure.blockedByStanding);
    expect(f.moveOf('b')!.to, isNull);
  });

  test('entering another train goal is reported', () {
    final level = buildLevel(
      nodes: [
        node('A', NodeKind.depot),
        node('G', NodeKind.goal),
        node('H', NodeKind.goal),
      ],
      edges: const ['AG'],
      trains: [trainDef('a', 'A', 'H')],
    );
    final f = PulseEngine(level).forecast(level.initialState, null);

    expect(f.conflict!.reason, PulseFailure.wrongGoal);
    expect(f.conflict!.nodeId, 'G');
  });

  test('forecast and pulse always agree', () {
    final level = ank02();
    final session = GameSession(level);
    for (final action in level.solution) {
      final f = session.forecast(action);
      final result = session.pulse(action);
      expect(f.ok, result is PulseApplied);
      final after = (result as PulseApplied).state;
      for (final move in f.moves) {
        expect(after.trainById(move.trainId)!.nodeId, move.to ?? move.from);
      }
      expect(f.delivers.toSet(), result.delivered.toSet());
    }
  });
}
