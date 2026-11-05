import 'board_state.dart';
import 'cell.dart';
import 'grid_pos.dart';
import 'train.dart';

/// Static description of a level as authored in `assets/levels/*.json`.
final class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.number,
    required this.width,
    required this.height,
    required this.cells,
    required this.initialTrains,
    this.initialSwitches = const {},
    required this.optimalMoves,
    this.tutorialKey,
  });

  final String id;
  final int number;
  final int width;
  final int height;

  /// Only non-empty cells are listed.
  final Map<GridPos, Cell> cells;
  final List<Train> initialTrains;
  final Map<GridPos, SwitchBranch> initialSwitches;
  final int optimalMoves;
  final String? tutorialKey;

  bool contains(GridPos pos) =>
      pos.x >= 0 && pos.y >= 0 && pos.x < width && pos.y < height;

  /// Unlisted cells are empty; cells outside the board behave as blocked.
  Cell cellAt(GridPos pos) {
    if (!contains(pos)) return const BlockedCell();
    return cells[pos] ?? const EmptyCell();
  }

  BoardState get initialState =>
      BoardState(trains: initialTrains, switches: initialSwitches);
}
