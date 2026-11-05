import 'grid_pos.dart';
import 'train_color.dart';

final class Train {
  const Train({
    required this.id,
    required this.color,
    required this.position,
    this.delivered = false,
  });

  final String id;
  final TrainColor color;
  final GridPos position;

  /// A delivered train has left the board and no longer occupies a cell.
  final bool delivered;

  Train copyWith({GridPos? position, bool? delivered}) => Train(
    id: id,
    color: color,
    position: position ?? this.position,
    delivered: delivered ?? this.delivered,
  );

  @override
  bool operator ==(Object other) =>
      other is Train &&
      other.id == id &&
      other.color == color &&
      other.position == position &&
      other.delivered == delivered;

  @override
  int get hashCode => Object.hash(id, color, position, delivered);

  @override
  String toString() => 'Train($id@$position${delivered ? ' delivered' : ''})';
}
