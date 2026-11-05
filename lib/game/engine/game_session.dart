import '../domain/control_action.dart';
import '../domain/game_state.dart';
import '../domain/level_definition.dart';
import '../domain/pulse_result.dart';
import 'pulse_engine.dart';
import 'undo_history.dart';

/// One play-through of a level: the current state plus unlimited undo.
/// Only successful pulses enter the history.
final class GameSession {
  GameSession(this.level, {PulseEngine? engine})
    : _engine = engine ?? PulseEngine(level),
      _state = level.initialState;

  final LevelDefinition level;
  final PulseEngine _engine;
  final UndoHistory<GameState> _history = UndoHistory();
  GameState _state;

  GameState get state => _state;
  int get pulses => _state.pulse;
  bool get isSolved => _engine.isSolved(_state);

  /// Out of pulses, or deadlocked so that no pulse can succeed.
  bool get isLost => _engine.isOutOfPulses(_state) || _engine.isStuck(_state);
  bool get isOutOfPulses => _engine.isOutOfPulses(_state);
  bool get canUndo => _history.canUndo;

  /// What [pulse] would do with [action], without playing it.
  PulseResult preview(ControlAction? action) =>
      _engine.simulatePulse(_state, action);

  PulseResult pulse(ControlAction? action) {
    final result = _engine.simulatePulse(_state, action);
    if (result is PulseApplied) {
      _history.push(_state);
      _state = result.state;
    }
    return result;
  }

  bool undo() {
    final previous = _history.pop();
    if (previous == null) return false;
    _state = previous;
    return true;
  }

  void restart() {
    _history.clear();
    _state = level.initialState;
  }
}
