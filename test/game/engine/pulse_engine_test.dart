import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/game_state.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/domain/train_state.dart';
import 'package:swipeout_last_train/game/engine/pulse_engine.dart';

import '../../support/graph_builders.dart';

GameState _applied(PulseResult r) {
  if (r is! PulseApplied) fail('expected PulseApplied, got $r');
  return r.state;
}

PulseFailure? _failure(PulseResult r) => r is PulseFailed ? r.reason : null;

/// L(depot) — M — N — R(depot), plus goals so every train has one.
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
  group('movement', () {
    test('a single train advances one edge per pulse', () {
      final level = ank01();
      final s = _applied(
        PulseEngine(level).simulatePulse(level.initialState, null),
      );

      expect(
        s.trainById('red_1'),
        const TrainState(id: 'red_1', nodeId: 'B', incomingEdgeId: 'AB'),
      );
      expect(s.pulse, 1);
    });

    test('the switch routes trunk traffic to the selected branch', () {
      final level = ank01();
      final engine = PulseEngine(level);
      final atB = _applied(engine.simulatePulse(level.initialState, null));

      final result =
          engine.simulatePulse(atB, const ToggleSwitch('B')) as PulseApplied;

      expect(result.state.trainById('red_1')!.delivered, isTrue);
      expect(result.delivered, ['red_1']);
      expect(engine.isSolved(result.state), isTrue);
    });

    test('the wrong branch leads into the terminal, where the train stays', () {
      final level = ank01();
      final engine = PulseEngine(level);
      var s = _applied(engine.simulatePulse(level.initialState, null));
      s = _applied(engine.simulatePulse(s, null));
      expect(s.trainById('red_1')!.nodeId, 'D');

      s = _applied(engine.simulatePulse(s, null));
      expect(s.trainById('red_1')!.nodeId, 'D');
    });

    test('a train arriving on the passive branch waits', () {
      final level = ank02();
      final engine = PulseEngine(level);
      final atB = _applied(engine.simulatePulse(level.initialState, null));

      expect(atB.trainById('red_1')!.incomingEdgeId, 'AB');
      expect(engine.nextNodeOf(atB, atB.trainById('red_1')!), isNull);
      expect(
        _applied(engine.simulatePulse(atB, null)).trainById('red_1')!.nodeId,
        'B',
      );
    });

    test('toggling the switch under a waiting train releases it', () {
      final level = ank02();
      final engine = PulseEngine(level);
      final atB = _applied(engine.simulatePulse(level.initialState, null));

      final s = _applied(engine.simulatePulse(atB, const ToggleSwitch('B')));

      expect(s.trainById('red_1')!.nodeId, 'C');
      expect(s.switches['B'], SwitchBranch.a);
    });

    test('red signal holds the train, green lets it go', () {
      final level = buildLevel(
        nodes: [
          node('L', NodeKind.depot),
          node('S', NodeKind.signal),
          node('G', NodeKind.goal),
        ],
        edges: const ['LS', 'SG'],
        trains: [trainDef('a', 'L', 'G')],
      );
      final engine = PulseEngine(level);
      final atS = stateOf(level, [at('a', 'S', 'LS')]);
      expect(atS.signals['S'], SignalAspect.red);

      expect(
        _applied(engine.simulatePulse(atS, null)).trainById('a')!.nodeId,
        'S',
      );
      final released = _applied(
        engine.simulatePulse(atS, const ToggleSignal('S')),
      );
      expect(released.trainById('a')!.delivered, isTrue);
      expect(released.signals['S'], SignalAspect.green);
    });

    test('a delivered train no longer occupies its goal', () {
      final level = ank01();
      final engine = PulseEngine(level);
      final atB = _applied(engine.simulatePulse(level.initialState, null));
      final done = _applied(engine.simulatePulse(atB, const ToggleSwitch('B')));

      expect(done.trainAt('C'), isNull);
    });
  });

  group('collisions leave the state untouched', () {
    test('two trains into one empty node collide', () {
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
      final s = level.initialState;

      final result = PulseEngine(level).simulatePulse(s, null) as PulseFailed;

      expect(result.reason, PulseFailure.collision);
      expect(result.trainIds, unorderedEquals(['a', 'b']));
      expect(result.nodeId, 'M');
    });

    test('a head-on swap collides', () {
      final level = _line();
      final s = stateOf(level, [at('a', 'M', 'LM'), at('b', 'N', 'NR')]);

      expect(
        _failure(PulseEngine(level).simulatePulse(s, null)),
        PulseFailure.headOn,
      );
    });

    test('running into a standing train collides', () {
      final level = buildLevel(
        nodes: [
          node('L', NodeKind.depot),
          node('M', NodeKind.track),
          node('T', NodeKind.terminal),
          node('G', NodeKind.goal),
        ],
        edges: const ['LM', 'MT'],
        trains: [trainDef('a', 'L', 'G'), trainDef('b', 'L', 'G')],
      );
      final s = stateOf(level, [at('a', 'M', 'LM'), at('b', 'T', 'MT')]);

      expect(
        _failure(PulseEngine(level).simulatePulse(s, null)),
        PulseFailure.blockedByStanding,
      );
    });

    test("entering another train's goal is a wrong-line error", () {
      final level = buildLevel(
        nodes: [
          node('L', NodeKind.depot),
          node('G', NodeKind.goal),
          node('H', NodeKind.goal),
          node('R', NodeKind.depot),
        ],
        edges: const ['LG', 'RH'],
        trains: [trainDef('a', 'L', 'H'), trainDef('b', 'R', 'G')],
      );

      final result = PulseEngine(level).simulatePulse(level.initialState, null);

      expect(_failure(result), PulseFailure.wrongGoal);
    });

    test(
      'a failed pulse keeps the pulse count and the pending control unused',
      () {
        final level = _line();
        final s = stateOf(level, [at('a', 'M', 'LM'), at('b', 'N', 'NR')]);

        final result = PulseEngine(level).simulatePulse(s, null);

        expect(result, isA<PulseFailed>());
        expect(s.pulse, 0);
      },
    );
  });

  group('simultaneous movement', () {
    test('a train may enter a node that is being vacated', () {
      final level = buildLevel(
        nodes: [
          node('L', NodeKind.depot),
          node('M', NodeKind.track),
          node('N', NodeKind.track),
          node('G', NodeKind.goal),
        ],
        edges: const ['LM', 'MN', 'NG'],
        trains: [trainDef('a', 'L', 'G'), trainDef('b', 'L', 'G')],
      );
      final s = stateOf(level, [at('a', 'M', 'LM'), at('b', 'L')]);

      final next = _applied(PulseEngine(level).simulatePulse(s, null));

      expect(next.trainById('a')!.nodeId, 'N');
      expect(next.trainById('b')!.nodeId, 'M');
    });

    test('a three-train rotation is allowed', () {
      final level = buildLevel(
        nodes: [
          node('X', NodeKind.track),
          node('Y', NodeKind.track),
          node('Z', NodeKind.track),
          node('G', NodeKind.goal),
        ],
        edges: const ['XY', 'YZ', 'ZX'],
        trains: [
          trainDef('a', 'X', 'G'),
          trainDef('b', 'Y', 'G'),
          trainDef('c', 'Z', 'G'),
        ],
      );
      final s = stateOf(level, [
        at('a', 'X', 'ZX'),
        at('b', 'Y', 'XY'),
        at('c', 'Z', 'YZ'),
      ]);

      final next = _applied(PulseEngine(level).simulatePulse(s, null));

      expect([for (final t in next.trains) t.nodeId], ['Y', 'Z', 'X']);
    });
  });

  group('guards', () {
    test('a control on the wrong kind of node is rejected', () {
      final level = ank01();
      final engine = PulseEngine(level);

      expect(
        _failure(
          engine.simulatePulse(level.initialState, const ToggleSwitch('A')),
        ),
        PulseFailure.invalidControl,
      );
      expect(
        _failure(
          engine.simulatePulse(level.initialState, const ToggleSignal('B')),
        ),
        PulseFailure.invalidControl,
      );
    });

    test('no pulse after the limit or after solving', () {
      final level = ank01();
      final engine = PulseEngine(level);
      final spent = level.initialState.copyWith(pulse: level.maxPulses);

      expect(
        _failure(engine.simulatePulse(spent, null)),
        PulseFailure.outOfPulses,
      );
      expect(engine.isOutOfPulses(spent), isTrue);

      final atB = _applied(engine.simulatePulse(level.initialState, null));
      final done = _applied(engine.simulatePulse(atB, const ToggleSwitch('B')));
      expect(
        _failure(engine.simulatePulse(done, null)),
        PulseFailure.alreadySolved,
      );
      expect(engine.isOutOfPulses(done), isFalse);
    });

    test(
      'actions offer waiting plus one toggle per control, in a fixed order',
      () {
        final level = ank01();

        expect(PulseEngine(level).actions(level.initialState).toList(), [
          null,
          const ToggleSwitch('B'),
        ]);
      },
    );
  });
}
