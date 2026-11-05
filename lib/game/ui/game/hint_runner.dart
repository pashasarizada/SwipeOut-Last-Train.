import 'package:flutter/foundation.dart';

import '../../domain/board_state.dart';
import '../../domain/level_definition.dart';
import '../../engine/level_solver.dart';

typedef HintRunner =
    Future<SolverOutcome> Function(LevelDefinition level, BoardState from);

/// Default [HintRunner]: solves on a background isolate so the UI never stalls.
Future<SolverOutcome> computeHint(LevelDefinition level, BoardState from) =>
    compute(_solve, (level, from));

SolverOutcome _solve((LevelDefinition, BoardState) args) =>
    const LevelSolver().solve(args.$1, from: args.$2);
