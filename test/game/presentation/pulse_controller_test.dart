import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/presentation/game/game_event.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';

import '../../support/graph_builders.dart';

/// A controller plus the events it emitted, flushed on demand.
Future<(PulseController, List<GameEvent>)> _start(LevelDefinition level) async {
  final c = PulseController(level: level);
  final events = <GameEvent>[];
  c.events.listen(events.add);
  addTearDown(c.dispose);
  return (c, events);
}

Future<void> _advanceAndSettle(PulseController c) async {
  c.advance();
  c.finishAnimation();
  await pumpEventQueue();
}

LevelDefinition _ank01Scored() {
  final base = ank01();
  return buildLevel(
    nodes: base.nodes.values.toList(),
    edges: base.edges.keys.toList(),
    switches: base.switches.values.toList(),
    initialSwitches: base.initialSwitches,
    trains: base.trains,
    maxPulses: base.maxPulses,
    parPulses: base.parPulses,
  );
}

void main() {
  group('pending control', () {
    test('tapping a switch selects it without changing the board', () async {
      final (c, _) = await _start(ank01());
      final before = c.state;

      c.tapNode('B');

      expect(c.pending, const ToggleSwitch('B'));
      expect(c.state, before);
      expect(c.pulses, 0);
    });

    test('tapping it again cancels; other nodes are ignored', () async {
      final (c, _) = await _start(ank01());
      c.tapNode('B');
      c.tapNode('B');
      expect(c.pending, isNull);

      c.tapNode('A');
      expect(c.pending, isNull);

      c.tapNode('B');
      c.cancelPending();
      expect(c.pending, isNull);
    });

    test('a signal node gives a signal toggle', () async {
      final level = buildLevel(
        nodes: [
          node('L', NodeKind.depot),
          node('S', NodeKind.signal),
          node('G', NodeKind.goal),
        ],
        edges: const ['LS', 'SG'],
        trains: [trainDef('a', 'L', 'G')],
      );
      final (c, _) = await _start(level);
      c.tapNode('S');
      expect(c.pending, const ToggleSignal('S'));
    });
  });

  group('advancing', () {
    test(
      'a committed pulse applies the pending control and locks input',
      () async {
        final (c, events) = await _start(ank02());
        c.tapNode('B');

        c.advance();
        await pumpEventQueue();

        expect(c.pulses, 1);
        expect(c.pending, isNull);
        expect(c.state.switches['B'], SwitchBranch.a);
        expect(c.isAnimating, isTrue);
        final committed = events.single as PulseCommitted;
        expect(committed.before.pulse, 0);
        expect(committed.after.pulse, 1);
      },
    );

    test('input is ignored while the pulse animates', () async {
      final (c, _) = await _start(ank01());
      c.advance();
      c.advance();
      c.tapNode('B');
      c.undo();
      expect(c.pulses, 1);
      expect(c.pending, isNull);

      c.finishAnimation();
      c.advance();
      expect(c.pulses, 2);
    });

    test('a rejected pulse keeps the pending control', () async {
      final (c, events) = await _start(wrongWayLevel());
      await _advanceAndSettle(c);
      c.tapNode('K');

      c.advance();
      await pumpEventQueue();

      final rejected = events.whereType<PulseRejected>().single;
      expect(rejected.reason, PulseFailure.wrongGoal);
      expect(rejected.nodeId, 'G');
      expect(c.pending, const ToggleSwitch('K'));
      expect(c.isAnimating, isFalse);
      expect(c.pulses, 1);
    });
  });

  group('outcome', () {
    test(
      'solving a tutorial wins without stars, after the animation',
      () async {
        final (c, events) = await _start(ank01());
        await _advanceAndSettle(c);
        c.tapNode('B');
        c.advance();
        await pumpEventQueue();
        expect(events.whereType<LevelWon>(), isEmpty);

        c.finishAnimation();
        await pumpEventQueue();

        final won = events.whereType<LevelWon>().single;
        expect(won.result.pulses, 2);
        expect(won.result.rating, isNull);
        expect(c.isSolved, isTrue);
      },
    );

    test('a scored level awards stars', () async {
      final (c, events) = await _start(_ank01Scored());
      await _advanceAndSettle(c);
      c.tapNode('B');
      await _advanceAndSettle(c);

      expect(
        events.whereType<LevelWon>().single.result.rating,
        StarRating.gold,
      );
    });

    test('running out of pulses loses; undo recovers', () async {
      final (c, events) = await _start(ank01());
      for (var i = 0; i < c.maxPulses; i++) {
        await _advanceAndSettle(c);
      }
      expect(c.isLost, isTrue);
      expect(events.whereType<LevelLost>(), hasLength(1));

      c.undo();
      expect(c.isLost, isFalse);
      expect(c.pulses, c.maxPulses - 1);
    });

    test(
      'undo restores pulses and switches; restart after winning starts over',
      () async {
        final (c, _) = await _start(ank02());
        c.tapNode('B');
        await _advanceAndSettle(c);
        c.undo();
        expect(c.pulses, 0);
        expect(c.state.switches['B'], SwitchBranch.b);

        c.tapNode('B');
        for (var i = 0; i < 3; i++) {
          await _advanceAndSettle(c);
        }
        expect(c.isSolved, isTrue);

        c.restart();
        expect(c.isSolved, isFalse);
        expect(c.pulses, 0);
      },
    );
  });

  test('reaching a jam ends the run once the pulse has played', () async {
    final (c, events) = await _start(jamLevel());
    expect(c.isLost, isFalse);

    await _advanceAndSettle(c);

    expect(c.isLost, isTrue);
    expect(events.whereType<LevelLost>().single.jammed, isTrue);
    c.undo();
    expect(c.isLost, isFalse);
  });

  test('running out of pulses is not a jam', () async {
    final (c, events) = await _start(ank01());
    for (var i = 0; i < c.maxPulses; i++) {
      await _advanceAndSettle(c);
    }
    expect(events.whereType<LevelLost>().single.jammed, isFalse);
  });

  test('calls after dispose are harmless', () async {
    final c = PulseController(level: ank01());
    c.advance();
    c.dispose();

    expect(c.finishAnimation, returnsNormally);
  });

  group('ghost', () {
    test('shows where trains will be after the pending control', () async {
      final (c, _) = await _start(ank01());
      expect(c.ghost!.trainById('red_1')!.nodeId, 'B');
      await _advanceAndSettle(c);
      // At the switch, B points away from the goal until it is turned.
      expect(c.ghost!.trainById('red_1')!.nodeId, 'D');
      c.tapNode('B');
      expect(c.ghost!.trainById('red_1')!.delivered, isTrue);
    });

    test(
      'is hidden while a pulse plays, on a rejected pulse and at the end',
      () async {
        final (c, _) = await _start(jamLevel());
        c.advance();
        expect(c.ghost, isNull, reason: 'animating');
        c.finishAnimation();
        expect(c.ghost, isNull, reason: 'the line is jammed');
      },
    );
  });
}
