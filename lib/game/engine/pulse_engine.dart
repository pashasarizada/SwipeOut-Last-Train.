import '../domain/control_action.dart';
import '../domain/edge.dart';
import '../domain/game_state.dart';
import '../domain/level_definition.dart';
import '../domain/node.dart';
import '../domain/pulse_forecast.dart';
import '../domain/pulse_result.dart';
import '../domain/signal_aspect.dart';
import '../domain/train_state.dart';

/// NIGHT PULSE rules: one optional control change, then every train moves at
/// once. Pure and atomic — a failed pulse changes nothing.
final class PulseEngine {
  PulseEngine(this.level);

  final LevelDefinition level;

  bool isSolved(GameState state) => state.allDelivered;

  bool isOutOfPulses(GameState state) =>
      !isSolved(state) && state.pulse >= level.maxPulses;

  /// No action can ever succeed again: every pulse from here fails and a
  /// failed pulse changes nothing, so the run is lost (deadlock).
  bool isStuck(GameState state) =>
      !isSolved(state) &&
      state.pulse < level.maxPulses &&
      actions(state).every((a) => simulatePulse(state, a) is PulseFailed);

  /// `null` (wait) first, then switches and signals by node id — a fixed
  /// order keeps the solver deterministic.
  Iterable<ControlAction?> actions(GameState state) => [
    null,
    for (final id in state.switches.keys.toList()..sort()) ToggleSwitch(id),
    for (final id in state.signals.keys.toList()..sort()) ToggleSignal(id),
  ];

  /// Applies only the control change; trains do not move.
  GameState applyAction(GameState state, ControlAction? action) =>
      switch (action) {
        null => state,
        ToggleSwitch(:final nodeId) => state.copyWith(
          switches: {
            ...state.switches,
            nodeId: state.switches[nodeId]!.toggled,
          },
        ),
        ToggleSignal(:final nodeId) => state.copyWith(
          signals: {...state.signals, nodeId: state.signals[nodeId]!.toggled},
        ),
      };

  /// The node [train] will enter this pulse, or null if it waits.
  String? nextNodeOf(GameState state, TrainState train) =>
      _exitEdge(state, train)?.other(train.nodeId);

  PulseResult simulatePulse(GameState state, ControlAction? action) =>
      switch (_plan(state, action)) {
        (failure: final failure?, controlled: _, exits: _) => failure,
        (failure: null, :final controlled, :final exits) => _commit(
          controlled,
          exits,
        ),
      };

  /// What [simulatePulse] would do, including every train's intent when
  /// the pulse would be rejected. Both share [_plan], so they never differ.
  PulseForecast forecast(GameState state, ControlAction? action) {
    final (:failure, :controlled, :exits) = _plan(state, action);
    final moves = [
      for (final train in controlled.activeTrains)
        TrainMove(
          trainId: train.id,
          from: train.nodeId,
          to: exits[train.id]?.other(train.nodeId),
        ),
    ];
    return PulseForecast(
      moves: moves,
      conflict: failure,
      delivers: failure != null
          ? const {}
          : {
              for (final move in moves)
                if (move.to != null &&
                    level.trainDef(move.trainId)!.goalNode == move.to)
                  move.trainId,
            },
    );
  }

  ({PulseFailed? failure, GameState controlled, Map<String, Edge> exits}) _plan(
    GameState state,
    ControlAction? action,
  ) {
    PulseFailed? early;
    if (isSolved(state)) {
      early = const PulseFailed(PulseFailure.alreadySolved);
    } else if (state.pulse >= level.maxPulses) {
      early = const PulseFailed(PulseFailure.outOfPulses);
    } else if (!_isValid(state, action)) {
      early = PulseFailed(PulseFailure.invalidControl, nodeId: action?.nodeId);
    }
    if (early != null) {
      return (failure: early, controlled: state, exits: const {});
    }
    final controlled = applyAction(state, action);
    final exits = <String, Edge>{
      for (final train in controlled.activeTrains)
        if (_exitEdge(controlled, train) case final edge?) train.id: edge,
    };
    return (
      failure: _conflict(controlled, exits),
      controlled: controlled,
      exits: exits,
    );
  }

  bool _isValid(GameState state, ControlAction? action) => switch (action) {
    null => true,
    ToggleSwitch(:final nodeId) => state.switches.containsKey(nodeId),
    ToggleSignal(:final nodeId) => state.signals.containsKey(nodeId),
  };

  Edge? _exitEdge(GameState state, TrainState train) {
    if (train.delivered) return null;
    final node = level.nodes[train.nodeId]!;
    final incoming = train.incomingEdgeId;
    switch (node.kind) {
      case NodeKind.junction:
        return _junctionExit(state, node.id, incoming);
      case NodeKind.signal when state.signals[node.id] == SignalAspect.red:
        return null;
      case NodeKind.depot ||
          NodeKind.track ||
          NodeKind.signal ||
          NodeKind.goal ||
          NodeKind.terminal:
        // The only edge other than the one we came by; none at a dead end.
        final candidates = level
            .edgesOf(node.id)
            .where((e) => e.id != incoming);
        return candidates.length == 1 ? candidates.single : null;
    }
  }

  Edge? _junctionExit(GameState state, String nodeId, String? incoming) {
    final sw = level.switches[nodeId]!;
    final active = sw.edgeFor(state.switches[nodeId]!);
    final exitId = incoming == sw.trunkEdge
        ? active
        : incoming == active
        ? sw.trunkEdge
        : null; // arrived on the passive branch (or no history): wait
    return exitId == null ? null : level.edges[exitId];
  }

  PulseFailed? _conflict(GameState state, Map<String, Edge> exits) {
    final targets = {
      for (final MapEntry(key: id, value: edge) in exits.entries)
        id: edge.other(state.trainById(id)!.nodeId),
    };

    final byTarget = <String, List<String>>{};
    targets.forEach((id, node) => (byTarget[node] ??= []).add(id));
    for (final MapEntry(key: node, value: ids) in byTarget.entries) {
      if (ids.length > 1) {
        return PulseFailed(PulseFailure.collision, trainIds: ids, nodeId: node);
      }
    }

    for (final MapEntry(key: id, value: target) in targets.entries) {
      final from = state.trainById(id)!.nodeId;
      final occupant = state.trainAt(target);
      if (occupant == null) continue;
      if (targets[occupant.id] == from) {
        return PulseFailed(
          PulseFailure.headOn,
          trainIds: [id, occupant.id],
          nodeId: target,
        );
      }
      if (!targets.containsKey(occupant.id)) {
        return PulseFailed(
          PulseFailure.blockedByStanding,
          trainIds: [id, occupant.id],
          nodeId: target,
        );
      }
    }

    for (final MapEntry(key: id, value: target) in targets.entries) {
      final isGoal = level.nodes[target]!.kind == NodeKind.goal;
      if (isGoal && level.trainDef(id)!.goalNode != target) {
        return PulseFailed(
          PulseFailure.wrongGoal,
          trainIds: [id],
          nodeId: target,
        );
      }
    }
    return null;
  }

  PulseApplied _commit(GameState state, Map<String, Edge> exits) {
    final delivered = <String>[];
    final trains = [
      for (final train in state.trains)
        if (exits[train.id] case final edge?)
          _arrive(train, edge, delivered)
        else
          train,
    ];
    return PulseApplied(
      state.copyWith(trains: trains, pulse: state.pulse + 1),
      delivered: delivered,
    );
  }

  TrainState _arrive(TrainState train, Edge edge, List<String> delivered) {
    final target = edge.other(train.nodeId);
    final home = level.trainDef(train.id)!.goalNode == target;
    if (home) delivered.add(train.id);
    return train.copyWith(
      nodeId: target,
      incomingEdgeId: edge.id,
      delivered: home,
    );
  }
}
