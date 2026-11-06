import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/game_state.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';
import 'package:swipeout_last_train/game/engine/hint_finder.dart';
import 'package:swipeout_last_train/game/presentation/game/game_event.dart';
import 'package:swipeout_last_train/game/presentation/game/hint_controller.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';

import '../../support/graph_builders.dart';

/// Works the hint out right here instead of on another isolate.
Future<Hint> _inline(
  LevelDefinition level,
  GameState state,
  List<ControlAction?> history,
) async => HintFinder(level).next(state, history);

LevelDefinition _scored() {
  final base = ank01();
  return buildLevel(
    nodes: base.nodes.values.toList(),
    edges: base.edges.keys.toList(),
    switches: base.switches.values.toList(),
    initialSwitches: base.initialSwitches,
    trains: base.trains,
    maxPulses: base.maxPulses,
    parPulses: base.parPulses,
  );
}

(PulseController, HintController) _start(
  LevelDefinition level, {
  HintRunner runner = _inline,
}) {
  final game = PulseController(level: level);
  final hints = HintController(game, runner: runner);
  addTearDown(() {
    hints.dispose();
    game.dispose();
  });
  return (game, hints);
}

Future<void> _advance(PulseController c) async {
  c.advance();
  c.finishAnimation();
  await pumpEventQueue();
}

void main() {
  test('a hint names the next move and marks the run', () async {
    final (game, hints) = _start(_scored());
    await hints.request();
    // ANK-01 needs a wait first: B still points at the terminal.
    expect(hints.hint, const HintAction(null));
    expect(game.hintUsed, isTrue);
  });

  test('the hint fades once the board moves on', () async {
    final (game, hints) = _start(_scored());
    await hints.request();
    await _advance(game);
    expect(hints.hint, isNull);
  });

  test('a hint that arrives after the player moved is dropped', () async {
    final late = Completer<Hint>();
    final (game, hints) = _start(_scored(), runner: (_, _, _) => late.future);
    final asked = hints.request();
    expect(hints.thinking, isTrue);
    await _advance(game);
    late.complete(const HintAction(null));
    await asked;
    expect(hints.hint, isNull);
    expect(hints.thinking, isFalse);
  });

  test('a hinted win keeps at most two stars', () async {
    final (game, hints) = _start(_scored());
    final events = <GameEvent>[];
    game.events.listen(events.add);
    await hints.request();
    await _advance(game);
    game.tapNode('B');
    await _advance(game);
    expect(
      events.whereType<LevelWon>().single.result.rating,
      StarRating.silver,
      reason: 'par pace, but hinted',
    );
  });

  test('restart clears the cost, undo does not', () async {
    final (game, hints) = _start(_scored());
    await _advance(game);
    await hints.request();
    game.undo();
    expect(game.hintUsed, isTrue);
    await _advance(game);
    game.restart();
    expect(game.hintUsed, isFalse);
  });
}
