import '../domain/board_state.dart';
import '../domain/cell.dart';
import '../domain/direction.dart';
import '../domain/grid_pos.dart';
import '../domain/level_definition.dart';
import '../domain/move.dart';
import '../domain/move_result.dart';
import 'track_connectivity.dart';

/// The single source of truth for what a move does. Pure and stateless.
final class GameRules {
  GameRules(this.level)
    : _tracks = TrackConnectivity(level),
      _switchPositions = _sortedSwitchPositions(level);

  final LevelDefinition level;
  final TrackConnectivity _tracks;
  final List<GridPos> _switchPositions;

  MoveResult apply(BoardState state, Move move) => switch (move) {
    TrainMove() => _moveTrain(state, move),
    SwitchToggle() => _toggleSwitch(state, move),
  };

  /// Applicable moves in a fixed order (trains by id × N/E/S/W, then switches
  /// by row and column) so that search over them is deterministic.
  Iterable<Move> legalMoves(BoardState state) sync* {
    final candidates = <Move>[
      for (final train in state.trains)
        if (!train.delivered)
          for (final direction in Direction.values)
            TrainMove(train.id, direction),
      for (final pos in _switchPositions) SwitchToggle(pos),
    ];
    for (final move in candidates) {
      if (apply(state, move) is MoveApplied) yield move;
    }
  }

  bool isSolved(BoardState state) => state.allDelivered;

  MoveResult _toggleSwitch(BoardState state, SwitchToggle move) {
    final pos = move.position;
    if (level.cellAt(pos) is! SwitchCell) {
      return const MoveRejected(RejectReason.notASwitch);
    }
    if (state.trainAt(pos) != null) {
      return const MoveRejected(RejectReason.switchOccupied);
    }
    return MoveApplied(state.withSwitch(pos, state.branchAt(pos).toggled));
  }

  static List<GridPos> _sortedSwitchPositions(LevelDefinition level) => [
    for (final entry in level.cells.entries)
      if (entry.value is SwitchCell) entry.key,
  ]..sort((a, b) => a.y != b.y ? a.y - b.y : a.x - b.x);

  MoveResult _moveTrain(BoardState state, TrainMove move) {
    final train = state.trainById(move.trainId);
    if (train == null) return const MoveRejected(RejectReason.unknownTrain);
    if (train.delivered) return const MoveRejected(RejectReason.trainDelivered);

    final from = train.position;
    if (!_tracks.openPorts(from, state).contains(move.direction)) {
      return const MoveRejected(RejectReason.noExit);
    }

    final to = from.step(move.direction);
    if (!_tracks.openPorts(to, state).contains(move.direction.opposite)) {
      return const MoveRejected(RejectReason.noEntry);
    }
    if (state.trainAt(to) != null) {
      return const MoveRejected(RejectReason.occupied);
    }

    final target = level.cellAt(to);
    if (target is StationCell) {
      if (target.color != train.color) {
        return const MoveRejected(RejectReason.wrongStation);
      }
      return MoveApplied(
        state.withTrain(train.copyWith(position: to, delivered: true)),
        deliveredTrainId: train.id,
      );
    }
    return MoveApplied(state.withTrain(train.copyWith(position: to)));
  }
}
