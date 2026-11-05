import 'package:flutter/material.dart';

import '../../domain/control_action.dart';
import '../../domain/level_definition.dart';
import '../game/game_scope.dart';
import 'pulse_game_screen.dart';

/// Opens [level] (optionally restoring a half-played run). "Next" replaces
/// the screen with the city's following level.
void openLevel(
  BuildContext context,
  LevelDefinition level, {
  List<ControlAction?> restore = const [],
  bool replace = false,
}) {
  final levels = GameScope.of(context).levelsOf(level.city);
  final index = levels.indexWhere((l) => l.id == level.id);
  final next = index >= 0 && index + 1 < levels.length
      ? levels[index + 1]
      : null;
  final route = MaterialPageRoute<void>(
    builder: (routeContext) => PulseGameScreen(
      level: level,
      restore: restore,
      onNext: next == null
          ? null
          : () => openLevel(routeContext, next, replace: true),
    ),
  );
  final navigator = Navigator.of(context);
  replace ? navigator.pushReplacement(route) : navigator.push(route);
}
