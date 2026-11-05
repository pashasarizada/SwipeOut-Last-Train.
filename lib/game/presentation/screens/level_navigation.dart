import 'package:flutter/material.dart';

import '../../domain/level_definition.dart';
import 'pulse_game_screen.dart';

/// Opens `levels[index]`; "Next" replaces the screen with the following one.
void openLevel(
  BuildContext context,
  List<LevelDefinition> levels,
  int index, {
  bool replace = false,
}) {
  final navigator = Navigator.of(context);
  final hasNext = index + 1 < levels.length;
  final route = MaterialPageRoute<void>(
    builder: (routeContext) => PulseGameScreen(
      level: levels[index],
      onNext: hasNext
          ? () => openLevel(routeContext, levels, index + 1, replace: true)
          : null,
    ),
  );
  replace ? navigator.pushReplacement(route) : navigator.push(route);
}
