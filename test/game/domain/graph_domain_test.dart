import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/edge.dart';
import 'package:swipeout_last_train/game/domain/game_state.dart';
import 'package:swipeout_last_train/game/domain/localized_text.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/domain/train_def.dart';
import 'package:swipeout_last_train/game/domain/train_state.dart';

import '../../support/graph_builders.dart';

void main() {
  const t1 = TrainState(id: 'a', nodeId: 'A');
  const t2 = TrainState(id: 'b', nodeId: 'B', incomingEdgeId: 'AB');

  test('edge knows its other end', () {
    const e = Edge(id: 'AB', a: 'A', b: 'B');
    expect(e.other('A'), 'B');
    expect(e.other('B'), 'A');
    expect(e.touches('A'), isTrue);
    expect(e.touches('C'), isFalse);
  });

  test('switch branches and signal aspects toggle', () {
    expect(SwitchBranch.a.toggled, SwitchBranch.b);
    expect(SignalAspect.red.toggled, SignalAspect.green);
    const sw = SwitchDef(
      nodeId: 'B',
      trunkEdge: 'AB',
      branchAEdge: 'BC',
      branchBEdge: 'BD',
    );
    expect(sw.edgeFor(SwitchBranch.a), 'BC');
    expect(sw.edgeFor(SwitchBranch.b), 'BD');
  });

  test('symbols keep colour from being the only cue', () {
    expect(TrainSymbol.values.map((s) => s.glyph), ['●', '▲', '■', '◆']);
  });

  group('GameState', () {
    GameState state(List<TrainState> trains, {int pulse = 0}) => GameState(
      trains: trains,
      switches: const {},
      signals: const {},
      pulse: pulse,
    );

    test('equality ignores train order', () {
      expect(state([t2, t1]), state([t1, t2]));
      expect(state([t2, t1]).hashCode, state([t1, t2]).hashCode);
    });

    test('search key ignores the pulse counter, equality does not', () {
      final s = state([t1]);
      expect(s.copyWith(pulse: 3).searchKey, s.searchKey);
      expect(s.copyWith(pulse: 3), isNot(s));
    });

    test('incoming edge is part of the identity', () {
      expect(
        state([const TrainState(id: 'a', nodeId: 'B', incomingEdgeId: 'AB')]),
        isNot(
          state([const TrainState(id: 'a', nodeId: 'B', incomingEdgeId: 'CB')]),
        ),
      );
    });

    test('delivered trains occupy nothing', () {
      final s = state([t1.copyWith(delivered: true)]);
      expect(s.trainAt('A'), isNull);
      expect(s.allDelivered, isTrue);
    });

    test('withTrain replaces by id', () {
      final s = state([t1, t2]).withTrain(t1.copyWith(nodeId: 'C'));
      expect(s.trainById('a')!.nodeId, 'C');
      expect(s.trainAt('B'), t2);
    });
  });

  group('LevelDefinition', () {
    test('adjacency and initial state', () {
      final level = ank01();
      expect(
        level.edgesOf('B').map((e) => e.id),
        unorderedEquals(['AB', 'BC', 'BD']),
      );
      final s = level.initialState;
      expect(s.trainById('red_1'), const TrainState(id: 'red_1', nodeId: 'A'));
      expect(s.switches, {'B': SwitchBranch.b});
      expect(s.pulse, 0);
    });

    test('every switch and signal is explicit in the initial state', () {
      final level = buildLevel(
        nodes: [
          node('A', NodeKind.depot),
          node('B', NodeKind.junction),
          node('S', NodeKind.signal),
        ],
        edges: const [],
        switches: [
          const SwitchDef(
            nodeId: 'B',
            trunkEdge: 'x',
            branchAEdge: 'y',
            branchBEdge: 'z',
          ),
        ],
        trains: [trainDef('t', 'A', 'S')],
      );
      expect(level.initialState.switches, {'B': SwitchBranch.a});
      expect(level.initialState.signals, {'S': SignalAspect.red});
    });

    test('collections are copied, so callers cannot mutate a level', () {
      final trains = [trainDef('t', 'A', 'C')];
      final level = buildLevel(
        nodes: [node('A', NodeKind.depot)],
        edges: const [],
        trains: trains,
      );
      trains.add(trainDef('u', 'A', 'C'));
      expect(level.trains, hasLength(1));
      expect(
        () => level.trains.add(trainDef('v', 'A', 'C')),
        throwsUnsupportedError,
      );
    });

    test('solution is stored as control actions', () {
      expect(ank01().solution, const [null, ToggleSwitch('B')]);
    });
  });

  test('stars follow the pulse count', () {
    expect([2, 3, 4, 5].map((p) => StarRating.forPulses(pulses: p, par: 2)), [
      StarRating.gold,
      StarRating.silver,
      StarRating.silver,
      StarRating.bronze,
    ]);
  });

  test('localized text picks the language', () {
    const t = LocalizedText(tr: 'İlk Sefer', en: 'First Departure');
    expect(t.of('tr'), 'İlk Sefer');
    expect(t.of('en'), 'First Departure');
    expect(t.of('de'), 'First Departure');
  });
}
