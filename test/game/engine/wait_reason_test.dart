import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/pulse_forecast.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/engine/pulse_engine.dart';

import '../../support/all_levels.dart';

/// Playtest: players could not tell why a train was waiting. The forecast
/// now says: a red signal, a switch set against it, or a dead end.
void main() {
  test('every waiting train says why, and moving trains say nothing', () {
    final seen = <WaitReason>{};
    for (final level in allLevels()) {
      final engine = PulseEngine(level);
      var state = level.initialState;
      for (final step in level.solution) {
        for (final move in engine.forecast(state, null).moves) {
          final node = level.nodes[move.from]!;
          if (move.moves) {
            expect(move.waitReason, isNull, reason: '${level.id} $move');
            continue;
          }
          final expected = switch (node.kind) {
            NodeKind.signal when state.signals[node.id] == SignalAspect.red =>
              WaitReason.redSignal,
            NodeKind.junction => WaitReason.switchAgainst,
            _ => WaitReason.deadEnd,
          };
          expect(move.waitReason, expected, reason: '${level.id} $move');
          seen.add(expected);
        }
        state = (engine.simulatePulse(state, step) as PulseApplied).state;
      }
    }
    expect(seen, containsAll([WaitReason.redSignal, WaitReason.switchAgainst]));
  });
}
