/// Where a train is now and which edge brought it there.
final class TrainState {
  const TrainState({
    required this.id,
    required this.nodeId,
    this.incomingEdgeId,
    this.delivered = false,
  });

  final String id;
  final String nodeId;

  /// Null while the train still stands in its depot.
  final String? incomingEdgeId;

  /// A delivered train has left the network and occupies nothing.
  final bool delivered;

  TrainState copyWith({
    String? nodeId,
    String? incomingEdgeId,
    bool? delivered,
  }) => TrainState(
    id: id,
    nodeId: nodeId ?? this.nodeId,
    incomingEdgeId: incomingEdgeId ?? this.incomingEdgeId,
    delivered: delivered ?? this.delivered,
  );

  String get key =>
      '$id@${delivered ? 'D' : '$nodeId<${incomingEdgeId ?? '-'}'}';

  @override
  bool operator ==(Object other) => other is TrainState && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'TrainState($key)';
}
