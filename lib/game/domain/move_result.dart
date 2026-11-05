import 'board_state.dart';

enum RejectReason {
  unknownTrain,
  trainDelivered,
  noExit,
  noEntry,
  occupied,
  wrongStation,
  notASwitch,
  switchOccupied,
}

sealed class MoveResult {
  const MoveResult();
}

final class MoveApplied extends MoveResult {
  const MoveApplied(this.state, {this.deliveredTrainId});

  final BoardState state;

  /// Set when this move delivered a train to its station.
  final String? deliveredTrainId;
}

final class MoveRejected extends MoveResult {
  const MoveRejected(this.reason);

  final RejectReason reason;

  @override
  bool operator ==(Object other) =>
      other is MoveRejected && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'MoveRejected(${reason.name})';
}
