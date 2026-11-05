/// The four grid directions. Screen-style coordinates: y grows downwards.
enum Direction {
  north(0, -1, 'N'),
  east(1, 0, 'E'),
  south(0, 1, 'S'),
  west(-1, 0, 'W');

  const Direction(this.dx, this.dy, this.code);

  final int dx;
  final int dy;

  /// Single-letter code used in level files.
  final String code;

  Direction get opposite => switch (this) {
    Direction.north => Direction.south,
    Direction.east => Direction.west,
    Direction.south => Direction.north,
    Direction.west => Direction.east,
  };
}
