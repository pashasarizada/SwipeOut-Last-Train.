import '../domain/board_state.dart';
import '../domain/level_definition.dart';
import '../domain/move.dart';
import '../domain/move_result.dart';
import 'game_rules.dart';
import 'undo_history.dart';

/// One play-through of a level: current state plus unlimited undo.
final class GameSession {
  GameSession(this.level, {GameRules? rules})
    : _rules = rules ?? GameRules(level),
      _state = level.initialState;

  final LevelDefinition level;
  final GameRules _rules;
  final UndoHistory<BoardState> _history = UndoHistory();
  BoardState _state;

  BoardState get state => _state;

  /// Each applied move adds one history entry, so the count follows undo.
  int get moveCount => _history.length;
  bool get isSolved => _rules.isSolved(_state);
  bool get canUndo => _history.canUndo;

  MoveResult play(Move move) {
    final result = _rules.apply(_state, move);
    if (result is MoveApplied) {
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
