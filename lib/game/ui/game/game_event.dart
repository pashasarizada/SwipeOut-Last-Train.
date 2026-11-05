import '../../domain/level_result.dart';
import '../../domain/move_result.dart';

/// One-shot effects for the UI (messages, haptics, result sheet).
sealed class GameEvent {
  const GameEvent();
}

final class MoveBlocked extends GameEvent {
  const MoveBlocked(this.reason);

  final RejectReason reason;
}

final class TrainDelivered extends GameEvent {
  const TrainDelivered(this.trainId);

  final String trainId;
}

final class LevelCompleted extends GameEvent {
  const LevelCompleted(this.result);

  final LevelResult result;
}

final class SelectTrainFirst extends GameEvent {
  const SelectTrainFirst();
}

final class HintUnavailable extends GameEvent {
  const HintUnavailable();
}
