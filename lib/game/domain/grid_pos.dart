import 'direction.dart';

/// A cell coordinate on the board.
final class GridPos {
  const GridPos(this.x, this.y);

  final int x;
  final int y;

  GridPos step(Direction direction) =>
      GridPos(x + direction.dx, y + direction.dy);

  @override
  bool operator ==(Object other) =>
      other is GridPos && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '$x,$y';
}
