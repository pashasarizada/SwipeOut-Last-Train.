import 'dart:collection';

import '../domain/control_action.dart';
import '../domain/game_state.dart';
import '../domain/level_definition.dart';
import '../domain/pulse_result.dart';
import 'pulse_engine.dart';

sealed class SolveResult {
  const SolveResult();
}

/// A shortest plan: one entry per pulse, `null` meaning wait.
final class Solved extends SolveResult {
  const Solved(this.plan);

  final List<ControlAction?> plan;
}

final class Unsolvable extends SolveResult {
  const Unsolvable();
}

/// The search gave up; this says nothing about solvability.
final class SearchLimitReached extends SolveResult {
  const SearchLimitReached();
}

typedef _Parent = ({String? parent, ControlAction? action});

/// Breadth-first search over pulses. Every pulse costs one, so the first
/// solved state generated is optimal. Deterministic because
/// [PulseEngine.actions] has a fixed order.
final class PulseSolver {
  const PulseSolver({this.maxStates = 200000});

  final int maxStates;

  SolveResult solve(LevelDefinition level, {GameState? from}) {
    final engine = PulseEngine(level);
    final start = from ?? level.initialState;
    if (engine.isSolved(start)) return const Solved([]);

    final visited = <String, _Parent>{
      start.searchKey: (parent: null, action: null),
    };
    final queue = Queue<GameState>()..add(start);

    while (queue.isNotEmpty) {
      final state = queue.removeFirst();
      for (final action in engine.actions(state)) {
        final result = engine.simulatePulse(state, action);
        if (result is! PulseApplied) continue;
        final next = result.state;
        if (visited.containsKey(next.searchKey)) continue;

        visited[next.searchKey] = (parent: state.searchKey, action: action);
        if (engine.isSolved(next)) {
          return Solved(_planTo(next.searchKey, visited));
        }
        if (visited.length > maxStates) return const SearchLimitReached();
        queue.add(next);
      }
    }
    return const Unsolvable();
  }

  List<ControlAction?> _planTo(String key, Map<String, _Parent> visited) {
    final plan = <ControlAction?>[];
    var node = visited[key]!;
    while (node.parent != null) {
      plan.add(node.action);
      node = visited[node.parent]!;
    }
    return plan.reversed.toList();
  }
}
