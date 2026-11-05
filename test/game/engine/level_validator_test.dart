import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/domain/train_def.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';

import '../../support/graph_builders.dart';

Set<LevelIssueCode> _codes(LevelDefinition level) =>
    const LevelValidator().validate(level).issues.map((i) => i.code).toSet();

/// ANK-01 with selected parts replaced.
LevelDefinition _ank01With({
  List<Node>? nodes,
  List<String>? edges,
  List<SwitchDef>? switches,
  Map<String, SignalAspect> initialSignals = const {},
  List<TrainDef>? trains,
  int? maxPulses,
  int? parPulses,
  List<ControlAction?>? solution,
}) {
  final base = ank01();
  return buildLevel(
    nodes: nodes ?? base.nodes.values.toList(),
    edges: edges ?? base.edges.keys.toList(),
    switches: switches ?? base.switches.values.toList(),
    initialSwitches: base.initialSwitches,
    initialSignals: initialSignals,
    trains: trains ?? base.trains,
    maxPulses: maxPulses ?? base.maxPulses,
    parPulses: parPulses ?? base.parPulses,
    solution: solution ?? base.solution,
  );
}

void main() {
  test('tutorial fixtures are valid and report their optimum', () {
    for (final level in [ank01(), ank02()]) {
      final result = const LevelValidator().validate(level);
      expect(result.issues, isEmpty, reason: level.id);
      expect(result.optimum, level.parPulses, reason: level.id);
    }
  });

  test('duplicate train ids', () {
    final trains = [trainDef('red_1', 'A', 'C'), trainDef('red_1', 'A', 'C')];
    expect(
      _codes(_ank01With(trains: trains)),
      contains(LevelIssueCode.duplicateId),
    );
  });

  test('references to missing nodes or edges', () {
    expect(
      _codes(_ank01With(edges: ['AB', 'BC', 'BD', 'BX'])),
      contains(LevelIssueCode.unknownReference),
    );
    expect(
      _codes(_ank01With(trains: [trainDef('red_1', 'A', 'Q')])),
      contains(LevelIssueCode.unknownReference),
    );
  });

  test('positions outside the unit square', () {
    final nodes = [
      ...ank01().nodes.values.where((n) => n.id != 'C'),
      node('C', NodeKind.goal, 1.2, 0.5),
    ];
    expect(
      _codes(_ank01With(nodes: nodes)),
      contains(LevelIssueCode.positionOutOfRange),
    );
  });

  test('a track with three exits is ambiguous', () {
    final nodes = [
      ...ank01().nodes.values.where((n) => n.id != 'B'),
      node('B', NodeKind.track),
    ];
    expect(
      _codes(_ank01With(nodes: nodes, switches: [])),
      contains(LevelIssueCode.ambiguousTrack),
    );
  });

  test('a depot with two edges has a bad degree', () {
    final nodes = [...ank01().nodes.values, node('E', NodeKind.terminal)];
    expect(
      _codes(_ank01With(nodes: nodes, edges: ['AB', 'BC', 'BD', 'AE'])),
      contains(LevelIssueCode.badDegree),
    );
  });

  test('switch edges must be three distinct edges of its node', () {
    const bad = SwitchDef(
      nodeId: 'B',
      trunkEdge: 'AB',
      branchAEdge: 'BC',
      branchBEdge: 'BC',
    );
    expect(
      _codes(_ank01With(switches: [bad])),
      contains(LevelIssueCode.invalidSwitch),
    );
    expect(
      _codes(_ank01With(switches: [])),
      contains(LevelIssueCode.invalidSwitch),
    );
  });

  test('signal state on a node that is not a signal', () {
    expect(
      _codes(_ank01With(initialSignals: {'A': SignalAspect.red})),
      contains(LevelIssueCode.signalOnNonSignalNode),
    );
  });

  test('trains start on depots and head for goal nodes', () {
    expect(
      _codes(_ank01With(trains: [trainDef('red_1', 'B', 'C')])),
      contains(LevelIssueCode.trainNotOnDepot),
    );
    expect(
      _codes(_ank01With(trains: [trainDef('red_1', 'A', 'D')])),
      contains(LevelIssueCode.goalNotGoalNode),
    );
  });

  test('two trains may not share a goal', () {
    final trains = [trainDef('a', 'A', 'C'), trainDef('b', 'A', 'C')];
    expect(
      _codes(_ank01With(trains: trains)),
      contains(LevelIssueCode.sharedGoalOrStart),
    );
  });

  test('par above the limit', () {
    expect(
      _codes(_ank01With(parPulses: 6)),
      contains(LevelIssueCode.parExceedsMax),
    );
  });

  test('a recorded solution that does not solve the level', () {
    expect(_codes(_ank01With(solution: const [null, null])), {
      LevelIssueCode.solutionFails,
    });
    expect(_codes(_ank01With(solution: const [])), {
      LevelIssueCode.solutionFails,
    });
  });

  test('par above the solver optimum', () {
    final result = const LevelValidator().validate(
      _ank01With(parPulses: 3, solution: const [null, ToggleSwitch('B'), null]),
    );
    expect(
      result.issues.map((i) => i.code),
      contains(LevelIssueCode.solutionFails),
    );
    final codes = const LevelValidator()
        .validate(
          _ank01With(parPulses: 3, solution: const [ToggleSwitch('B'), null]),
        )
        .issues
        .map((i) => i.code);
    expect(codes, contains(LevelIssueCode.parAboveOptimum));
  });

  test('a structurally valid level that cannot be solved in time', () {
    final codes = _codes(
      _ank01With(
        maxPulses: 1,
        parPulses: 1,
        solution: const [ToggleSwitch('B')],
      ),
    );
    expect(
      codes,
      containsAll([LevelIssueCode.solutionFails, LevelIssueCode.unsolvable]),
    );
  });
}
