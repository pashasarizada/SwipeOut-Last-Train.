import '../domain/board_state.dart';
import '../domain/cell.dart';
import '../domain/direction.dart';
import '../domain/grid_pos.dart';
import '../domain/level_definition.dart';

/// Answers which ports of a cell are open in a given state.
final class TrackConnectivity {
  const TrackConnectivity(this.level);

  final LevelDefinition level;

  Set<Direction> openPorts(GridPos pos, BoardState state) =>
      switch (level.cellAt(pos)) {
        TrackCell(:final ports) || StationCell(:final ports) => ports,
        final SwitchCell cell => cell.portsFor(
          state.switches[pos] ?? SwitchBranch.a,
        ),
        EmptyCell() || BlockedCell() => const {},
      };
}
