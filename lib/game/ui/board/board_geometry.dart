import 'dart:math' as math;
import 'dart:ui';

import '../../domain/grid_pos.dart';

/// Maps grid coordinates to pixels and back. Shared by painting and input.
final class BoardGeometry {
  BoardGeometry({
    required this.columns,
    required this.rows,
    required Size available,
  }) : cellSize = math.min(available.width / columns, available.height / rows);

  final int columns;
  final int rows;
  final double cellSize;

  Size get boardSize => Size(cellSize * columns, cellSize * rows);

  Offset centerOf(GridPos pos) =>
      Offset((pos.x + 0.5) * cellSize, (pos.y + 0.5) * cellSize);

  GridPos? cellAt(Offset local) {
    if (local.dx < 0 || local.dy < 0) return null;
    final x = local.dx ~/ cellSize;
    final y = local.dy ~/ cellSize;
    if (x >= columns || y >= rows) return null;
    return GridPos(x, y);
  }

  @override
  bool operator ==(Object other) =>
      other is BoardGeometry &&
      other.columns == columns &&
      other.rows == rows &&
      other.cellSize == cellSize;

  @override
  int get hashCode => Object.hash(columns, rows, cellSize);
}
