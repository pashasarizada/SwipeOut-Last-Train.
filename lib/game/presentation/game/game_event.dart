import '../../domain/game_state.dart';
import '../../domain/level_result.dart';
import '../../domain/pulse_result.dart';

/// One-shot effects for the screen: animations, haptics, result sheets.
sealed class GameEvent {
  const GameEvent();
}

/// Play the tween from [before] to [after], then call `finishAnimation`.
final class PulseCommitted extends GameEvent {
  const PulseCommitted(this.before, this.after, this.delivered);

  final GameState before;
  final GameState after;
  final List<String> delivered;
}

/// Nothing changed; flash the conflict.
final class PulseRejected extends GameEvent {
  const PulseRejected(this.reason, this.trainIds, this.nodeId);

  final PulseFailure reason;
  final List<String> trainIds;
  final String? nodeId;
}

final class LevelWon extends GameEvent {
  const LevelWon(this.result);

  final LevelResult result;
}

final class LevelLost extends GameEvent {
  const LevelLost();
}
