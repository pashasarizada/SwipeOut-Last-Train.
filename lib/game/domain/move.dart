import 'direction.dart';
import 'grid_pos.dart';

/// A player action. Every applied move costs exactly one move count.
sealed class Move {
  const Move();
}

final class TrainMove extends Move {
  const TrainMove(this.trainId, this.direction);

  final String trainId;
  final Direction direction;

  @override
  bool operator ==(Object other) =>
      other is TrainMove &&
      other.trainId == trainId &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(trainId, direction);

  @override
  String toString() => 'TrainMove($trainId ${direction.code})';
}

final class SwitchToggle extends Move {
  const SwitchToggle(this.position);

  final GridPos position;

  @override
  bool operator ==(Object other) =>
      other is SwitchToggle && other.position == position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() => 'SwitchToggle($position)';
}
