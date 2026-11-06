part of 'pulse_engine.dart';

/// Why a pulse would be rejected: two trains into one node, a head-on
/// swap, a train into one that stays, or a train into another's goal.
extension _Conflicts on PulseEngine {
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
}
