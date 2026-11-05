import 'game_state.dart';

enum PulseFailure {
  /// Two trains want the same node.
  collision,

  /// Two trains would swap places along one edge.
  headOn,

  /// A train runs into one that stays where it is.
  blockedByStanding,

  /// A train enters a goal that belongs to another train.
  wrongGoal,

  /// The pulse limit is already used up.
  outOfPulses,

  /// Every train is already delivered.
  alreadySolved,

  /// The action names a node that is not that kind of control.
  invalidControl,
}

/// Outcome of one atomic pulse: either a new state, or nothing changed.
sealed class PulseResult {
  const PulseResult();
}

final class PulseApplied extends PulseResult {
  const PulseApplied(this.state, {this.delivered = const []});

  final GameState state;

  /// Ids of trains delivered by this pulse.
  final List<String> delivered;
}

final class PulseFailed extends PulseResult {
  const PulseFailed(this.reason, {this.trainIds = const [], this.nodeId});

  final PulseFailure reason;
  final List<String> trainIds;
  final String? nodeId;

  @override
  String toString() => 'PulseFailed(${reason.name} $trainIds @$nodeId)';
}
