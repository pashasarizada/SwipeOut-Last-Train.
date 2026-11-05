import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';
import 'package:swipeout_last_train/game/engine/pulse_engine.dart';
import 'package:swipeout_last_train/game/engine/pulse_solver.dart';

Object? _read(String file) =>
    jsonDecode(File('${LevelIndex.assetDir}/$file').readAsStringSync());

void main() {
  final index = LevelIndex.fromJson(_read(LevelIndex.fileName));
  final levels = <LevelDefinition>[
    for (final city in CityId.values)
      for (final file in index.filesFor(city))
        const LevelJsonCodec().decode(_read(file)! as Map<String, Object?>),
  ];

  test('the index lists all five cities in order', () {
    expect(index.cities, CityId.values);
  });

  for (final level in levels) {
    test('${level.id} passes validation', () {
      final result = const LevelValidator().validate(level);
      expect(result.issues, isEmpty);
    });
  }

  test('ids are unique and follow the city prefix', () {
    expect(levels.map((l) => l.id).toSet(), hasLength(levels.length));
    for (final level in levels) {
      expect(level.id, startsWith(LevelIndex.prefixOf(level.city)));
    }
  });

  test('Ankara starts with the two tutorial levels', () {
    expect(levels.take(2).map((l) => (l.id, l.parPulses, l.tutorial)), [
      ('ANK-01', 2, true),
      ('ANK-02', 3, true),
    ]);
  });

  test('ANK-03 is the first starred level: two trains, two switches', () {
    final level = levels.firstWhere((l) => l.id == 'ANK-03');
    expect((level.parPulses, level.tutorial), (2, false));
    expect(level.trains, hasLength(2));
    expect(level.switches, hasLength(2));
  });

  test('ANK-03 punishes waiting: the trains meet head-on', () {
    final level = levels.firstWhere((l) => l.id == 'ANK-03');
    final engine = PulseEngine(level);
    final first = engine.simulatePulse(level.initialState, null);
    final atSwitches = (first as PulseApplied).state;
    final second = engine.simulatePulse(atSwitches, null);
    expect(second, isA<PulseFailed>());
    expect((second as PulseFailed).reason, PulseFailure.headOn);
  });

  test('ANK-04: whoever waits at the transfer blocks the other train', () {
    final level = levels.firstWhere((l) => l.id == 'ANK-04');
    expect((level.parPulses, level.trains.length), (4, 2));
    final engine = PulseEngine(level);
    final first = engine.simulatePulse(level.initialState, null);
    final second = engine.simulatePulse((first as PulseApplied).state, null);
    expect((second as PulseFailed).reason, PulseFailure.blockedByStanding);
  });

  test('ANK-05: the clock is tight, a wasted first minute loses', () {
    final level = levels.firstWhere((l) => l.id == 'ANK-05');
    expect((level.parPulses, level.maxPulses), (4, 4));
    final waited = PulseEngine(level).simulatePulse(level.initialState, null);
    expect(
      const PulseSolver().solve(level, from: (waited as PulseApplied).state),
      isA<Unsolvable>(),
    );
  });

  test('Ankara is complete: six levels, the finale has a corridor', () {
    final ankara = levels.where((l) => l.city == CityId.ankara).toList();
    expect(ankara.map((l) => l.number), [1, 2, 3, 4, 5, 6]);
    final finale = ankara.last;
    expect(
      (finale.nodes.length, finale.switches.length, finale.parPulses),
      (8, 2, 5),
    );
  });

  test('BAK-01: opposite directions on one track, red must clear first', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-01');
    expect((level.city, level.parPulses), (CityId.baku, 5));
    final engine = PulseEngine(level);
    var state = level.initialState;
    for (var i = 0; i < 5; i++) {
      final next = engine.simulatePulse(state, null);
      if (next is! PulseApplied) {
        expect((next as PulseFailed).reason, PulseFailure.blockedByStanding);
        return;
      }
      state = next.state;
    }
    fail('waiting never blocks the line');
  });

  test('BAK-02: a train sent onto the siding can never be delivered', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-02');
    final engine = PulseEngine(level);
    var state = level.initialState;
    for (var i = 0; i < 3; i++) {
      state = (engine.simulatePulse(state, null) as PulseApplied).state;
    }
    expect(state.trainById('red_1')!.nodeId, 'Z');
    expect(const PulseSolver().solve(level, from: state), isA<Unsolvable>());
  });

  test('BAK-03: red must take the bypass, the transfer is for blue', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-03');
    final session = level.solution.fold(level.initialState, (state, action) {
      final next = PulseEngine(level).simulatePulse(state, action);
      return (next as PulseApplied).state;
    });
    expect(session.trains.every((t) => t.delivered), isTrue);
    expect(level.parPulses, 4);
  });

  test(
    'BAK-04: both trains reach the junction together unless one is held',
    () {
      final level = levels.firstWhere((l) => l.id == 'BAK-04');
      final engine = PulseEngine(level);
      final first = engine.simulatePulse(level.initialState, null);
      final second = engine.simulatePulse((first as PulseApplied).state, null);
      expect((second as PulseFailed).reason, PulseFailure.collision);
      expect(level.solution.whereType<ToggleSwitch>(), hasLength(6));
    },
  );

  test('BAK-05: rushing red into the corridor meets blue head-on', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-05');
    final engine = PulseEngine(level);
    var state = level.initialState;
    PulseResult result = PulseApplied(state);
    for (var i = 0; i < 3 && result is PulseApplied; i++) {
      state = result.state;
      result = engine.simulatePulse(state, null);
    }
    expect((result as PulseFailed).reason, PulseFailure.headOn);
  });

  test('Baku is complete: six levels, the finale has no spare minute', () {
    final baku = levels.where((l) => l.city == CityId.baku).toList();
    expect(baku.map((l) => l.number), [1, 2, 3, 4, 5, 6]);
    expect((baku.last.parPulses, baku.last.maxPulses), (8, 8));
  });

  test('PAR-01: Paris opens with crossing routes through one transfer', () {
    final level = levels.firstWhere((l) => l.id == 'PAR-01');
    expect(
      (level.city, level.parPulses, level.initialSignals.isEmpty),
      (CityId.paris, 6, true),
    );
  });

  test('PAR-02: the first signal holds red so blue can pass', () {
    final level = levels.firstWhere((l) => l.id == 'PAR-02');
    expect(level.initialSignals.keys, ['G']);
    expect(level.solution.whereType<ToggleSignal>(), hasLength(2));
  });

  test('PAR-03: both signals matter, one control per minute', () {
    final level = levels.firstWhere((l) => l.id == 'PAR-03');
    final used = level.solution.whereType<ToggleSignal>().map((a) => a.nodeId);
    expect(used.toSet(), {'G', 'H'});
    expect(level.parPulses, 7);
  });

  test('PAR-04: three trains, a control every single minute', () {
    final level = levels.firstWhere((l) => l.id == 'PAR-04');
    expect(level.trains, hasLength(3));
    expect(level.solution.every((a) => a != null), isTrue);
  });

  test('PAR-05: three trains, both signals start red', () {
    final level = levels.firstWhere((l) => l.id == 'PAR-05');
    expect(level.trains, hasLength(3));
    expect(level.initialSignals.values.toSet(), {SignalAspect.red});
    expect((level.parPulses, level.maxPulses), (8, 9));
  });

  test('Paris is complete: the finale uses every switch and signal', () {
    final paris = levels.where((l) => l.city == CityId.paris).toList();
    expect(paris.map((l) => l.number), [1, 2, 3, 4, 5, 6]);
    final finale = paris.last;
    final touched = {
      for (final a in finale.solution)
        if (a case ToggleSwitch(:final nodeId) || ToggleSignal(:final nodeId))
          nodeId,
    };
    expect(touched, {...finale.switches.keys, ...finale.initialSignals.keys});
  });

  test('LON-01: a missed exit sends the train round the ring', () {
    final level = levels.firstWhere((l) => l.id == 'LON-01');
    final engine = PulseEngine(level);
    // The recorded solution, but the last minute's exit switch is missed.
    final missed = [...level.solution.take(level.solution.length - 1), null];
    var state = level.initialState;
    for (final action in missed) {
      state = (engine.simulatePulse(state, action) as PulseApplied).state;
    }
    expect(state.trainById('red_1')!.nodeId, 'Z');
    expect(state.trainById('red_1')!.delivered, isFalse);
  });
}
