import '../domain/board_state.dart';
import '../domain/cell.dart';
import '../domain/level_definition.dart';
import '../domain/move.dart';
import '../domain/move_result.dart';
import 'track_connectivity.dart';

/// The single source of truth for what a move does. Pure and stateless.
final class GameRules {
  GameRules(this.level) : _tracks = TrackConnectivity(level);

  final LevelDefinition level;
  final TrackConnectivity _tracks;

  MoveResult apply(BoardState state, Move move) => switch (move) {
    TrainMove() => _moveTrain(state, move),
    SwitchToggle() => const MoveRejected(RejectReason.notASwitch),
  };

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
