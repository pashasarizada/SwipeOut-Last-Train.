import '../domain/control_action.dart';
import '../domain/game_state.dart';
import '../domain/level_definition.dart';
import 'pulse_solver.dart';

/// One step of help: the next control (or a wait), never the whole plan.
sealed class Hint {
  const Hint();
}

/// Play [action] next (`null` = just pull the lever).
final class HintAction extends Hint {
  const HintAction(this.action);

  final ControlAction? action;

  @override
  bool operator ==(Object other) =>
      other is HintAction && other.action == action;

  @override
  int get hashCode => action.hashCode;

  @override
  String toString() => 'HintAction($action)';
}

/// No way forward from here in time: undo.
final class HintUndo extends Hint {
  const HintUndo();

  @override
  bool operator ==(Object other) => other is HintUndo;

  @override
  int get hashCode => 7;

  @override
  String toString() => 'HintUndo()';
}

/// Finds the next right move: the recorded solution while the run still
/// follows it (instant, and safe for big Moscow boards), otherwise the
/// solver from the current state. Pure and synchronous — callers run it
/// off the UI thread.
final class HintFinder {
  HintFinder(this.level, {this.solver = const PulseSolver()});

  final LevelDefinition level;
  final PulseSolver solver;

  Hint next(GameState state, List<ControlAction?> history) {
    if (_followsSolution(history)) {
      return HintAction(level.solution[history.length]);
    }
    return switch (solver.solve(level, from: state)) {
      Solved(:final plan) when plan.isNotEmpty => HintAction(plan.first),
      _ => const HintUndo(),
    };
  }

  bool _followsSolution(List<ControlAction?> history) {
    final solution = level.solution;
    if (history.length >= solution.length) return false;
    for (var i = 0; i < history.length; i++) {
      if (history[i] != solution[i]) return false;
    }
    return true;
  }
}
