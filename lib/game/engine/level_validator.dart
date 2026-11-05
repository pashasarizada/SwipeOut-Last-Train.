import '../domain/level_definition.dart';
import '../domain/node.dart';
import '../domain/pulse_result.dart';
import 'game_session.dart';
import 'pulse_solver.dart';

enum LevelIssueCode {
  duplicateId,
  unknownReference,
  positionOutOfRange,
  ambiguousTrack,
  badDegree,
  invalidSwitch,
  signalOnNonSignalNode,
  trainNotOnDepot,
  goalNotGoalNode,
  sharedGoalOrStart,
  parExceedsMax,
  solutionFails,
  parAboveOptimum,
  unsolvable,
}

final class LevelIssue {
  const LevelIssue(this.code, {this.at, this.detail = ''});

  final LevelIssueCode code;
  final String? at;
  final String detail;

  @override
  String toString() =>
      '${code.name}${at == null ? '' : ' @$at'}${detail.isEmpty ? '' : ': $detail'}';
}

final class ValidationResult {
  const ValidationResult(this.issues, {this.solve});

  final List<LevelIssue> issues;

  /// Solver outcome; absent when structural issues stopped validation early.
  final SolveResult? solve;

  bool get isValid => issues.isEmpty;

  int? get optimum => switch (solve) {
    Solved(:final plan) => plan.length,
    _ => null,
  };
}

/// Structure first; only a well-formed level is replayed and solved.
final class LevelValidator {
  const LevelValidator({this.solver = const PulseSolver()});

  final PulseSolver solver;

  ValidationResult validate(LevelDefinition level) {
    final structural = [
      ..._references(level),
      ..._nodes(level),
      ..._switches(level),
      ..._trains(level),
      if (level.parPulses < 1 || level.parPulses > level.maxPulses)
        LevelIssue(
          LevelIssueCode.parExceedsMax,
          detail: 'par ${level.parPulses}, max ${level.maxPulses}',
        ),
    ];
    if (structural.isNotEmpty) return ValidationResult(structural);

    final solve = solver.solve(level);
    return ValidationResult([
      ..._replay(level),
      ...switch (solve) {
        Solved(:final plan) when plan.length < level.parPulses => [
          LevelIssue(
            LevelIssueCode.parAboveOptimum,
            detail: 'par ${level.parPulses}, solver found ${plan.length}',
          ),
        ],
        Unsolvable() => const [LevelIssue(LevelIssueCode.unsolvable)],
        // A state-limit stop is not an error: the recorded solution is proof.
        Solved() || SearchLimitReached() => const <LevelIssue>[],
      },
    ], solve: solve);
  }

  Iterable<LevelIssue> _references(LevelDefinition level) sync* {
    bool node(String id) => level.nodes.containsKey(id);
    for (final e in level.edges.values) {
      if (!node(e.a) || !node(e.b)) {
        yield LevelIssue(LevelIssueCode.unknownReference, at: e.id);
      }
    }
    for (final s in level.switches.values) {
      final edges = [s.trunkEdge, s.branchAEdge, s.branchBEdge];
      if (!node(s.nodeId) || !edges.every(level.edges.containsKey)) {
        yield LevelIssue(LevelIssueCode.unknownReference, at: s.nodeId);
      }
    }
    for (final id in level.initialSignals.keys) {
      if (!node(id)) yield LevelIssue(LevelIssueCode.unknownReference, at: id);
    }
    for (final t in level.trains) {
      if (!node(t.startNode) || !node(t.goalNode)) {
        yield LevelIssue(LevelIssueCode.unknownReference, at: t.id);
      }
    }
  }

  static const Map<NodeKind, int> _degree = {
    NodeKind.depot: 1,
    NodeKind.goal: 1,
    NodeKind.terminal: 1,
    NodeKind.junction: 3,
  };

  Iterable<LevelIssue> _nodes(LevelDefinition level) sync* {
    for (final n in level.nodes.values) {
      if (!n.position.isInUnitSquare) {
        yield LevelIssue(LevelIssueCode.positionOutOfRange, at: n.id);
      }
      final degree = level.edgesOf(n.id).length;
      final isPassThrough =
          n.kind == NodeKind.track || n.kind == NodeKind.signal;
      if (isPassThrough && degree != 2) {
        yield LevelIssue(
          LevelIssueCode.ambiguousTrack,
          at: n.id,
          detail: '$degree edges',
        );
      } else if (_degree[n.kind] case final want? when degree != want) {
        yield LevelIssue(
          LevelIssueCode.badDegree,
          at: n.id,
          detail: '${n.kind.name} has $degree edges, needs $want',
        );
      }
    }
    for (final id in level.initialSignals.keys) {
      if (level.nodes[id]?.kind != NodeKind.signal) {
        yield LevelIssue(LevelIssueCode.signalOnNonSignalNode, at: id);
      }
    }
  }

  Iterable<LevelIssue> _switches(LevelDefinition level) sync* {
    final junctions = level.nodes.values.where(
      (n) => n.kind == NodeKind.junction,
    );
    for (final n in junctions) {
      if (!level.switches.containsKey(n.id)) {
        yield LevelIssue(
          LevelIssueCode.invalidSwitch,
          at: n.id,
          detail: 'no switch',
        );
      }
    }
    for (final s in level.switches.values) {
      final edges = {s.trunkEdge, s.branchAEdge, s.branchBEdge};
      final allTouch = edges.every(
        (id) => level.edges[id]?.touches(s.nodeId) ?? false,
      );
      if (level.nodes[s.nodeId]?.kind != NodeKind.junction ||
          edges.length != 3 ||
          !allTouch) {
        yield LevelIssue(LevelIssueCode.invalidSwitch, at: s.nodeId);
      }
    }
  }

  Iterable<LevelIssue> _trains(LevelDefinition level) sync* {
    final ids = <String>{};
    final starts = <String>{};
    final goals = <String>{};
    for (final t in level.trains) {
      if (!ids.add(t.id)) {
        yield LevelIssue(LevelIssueCode.duplicateId, at: t.id);
      }
      if (!starts.add(t.startNode) || !goals.add(t.goalNode)) {
        yield LevelIssue(LevelIssueCode.sharedGoalOrStart, at: t.id);
      }
      if (level.nodes[t.startNode]?.kind != NodeKind.depot) {
        yield LevelIssue(LevelIssueCode.trainNotOnDepot, at: t.id);
      }
      if (level.nodes[t.goalNode]?.kind != NodeKind.goal) {
        yield LevelIssue(LevelIssueCode.goalNotGoalNode, at: t.id);
      }
    }
  }

  /// The recorded solution must solve the level in exactly `parPulses`.
  Iterable<LevelIssue> _replay(LevelDefinition level) sync* {
    final session = GameSession(level);
    for (final (i, action) in level.solution.indexed) {
      if (session.pulse(action) case PulseFailed(:final reason)) {
        yield LevelIssue(
          LevelIssueCode.solutionFails,
          detail: 'step ${i + 1}: ${reason.name}',
        );
        return;
      }
    }
    if (!session.isSolved || level.solution.length != level.parPulses) {
      yield LevelIssue(
        LevelIssueCode.solutionFails,
        detail:
            '${level.solution.length} steps, solved: ${session.isSolved}, par ${level.parPulses}',
      );
    }
  }
}
