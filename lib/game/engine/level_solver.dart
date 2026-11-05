import 'dart:collection';

import '../domain/board_state.dart';
import '../domain/level_definition.dart';
import '../domain/move.dart';
import 'game_rules.dart';

sealed class SolverOutcome {
  const SolverOutcome();
}

/// A shortest solution (every move costs one, so BFS order is optimal).
final class Solved extends SolverOutcome {
  const Solved(this.moves);

  final List<Move> moves;
}

final class Unsolvable extends SolverOutcome {
  const Unsolvable();
}

final class SearchLimitReached extends SolverOutcome {
  const SearchLimitReached();
}

typedef _Parent = ({String? parentKey, Move? move});

/// Breadth-first search over [BoardState]s. Deterministic because
/// [GameRules.legalMoves] yields moves in a fixed order.
final class LevelSolver {
  const LevelSolver({this.maxStates = 200000});

  final int maxStates;

  SolverOutcome solve(LevelDefinition level, {BoardState? from}) {
    final rules = GameRules(level);
    final start = from ?? level.initialState;
    final visited = <String, _Parent>{start.key: (parentKey: null, move: null)};
    final queue = Queue<BoardState>()..add(start);

    while (queue.isNotEmpty) {
      final state = queue.removeFirst();
      if (rules.isSolved(state)) return Solved(_pathTo(state.key, visited));

      for (final (:move, :next) in rules.transitions(state)) {
        if (visited.containsKey(next.key)) continue;
        if (visited.length >= maxStates) return const SearchLimitReached();
        visited[next.key] = (parentKey: state.key, move: move);
        queue.add(next);
      }
    }
    return const Unsolvable();
  }

  List<Move> _pathTo(String key, Map<String, _Parent> visited) {
    final moves = <Move>[];
    var current = visited[key]!;
    while (current.move != null) {
      moves.add(current.move!);
      current = visited[current.parentKey]!;
    }
    return moves.reversed.toList();
  }
}
