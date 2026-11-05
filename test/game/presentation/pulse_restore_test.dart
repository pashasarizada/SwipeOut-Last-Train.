import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';

import '../../support/graph_builders.dart';

void main() {
  test('history records committed pulses and follows undo and restart', () {
    final c = PulseController(level: ank02());
    addTearDown(c.dispose);
    c.tapNode('B');
    c.advance();
    c.finishAnimation();
    c.advance();
    c.finishAnimation();
    expect(c.history, const [ToggleSwitch('B'), null]);

    c.undo();
    expect(c.history, const [ToggleSwitch('B')]);
    c.restart();
    expect(c.history, isEmpty);
  });

  test('restore replays the saved actions', () {
    final c = PulseController.restore(
      level: ank02(),
      actions: const [ToggleSwitch('B'), null],
    );
    addTearDown(c.dispose);
    expect(c.pulses, 2);
    expect(c.state.trainById('red_1')!.nodeId, 'C');
    expect(c.history, const [ToggleSwitch('B'), null]);
    expect(c.canUndo, isTrue);
  });

  test('an invalid saved run starts the level fresh', () {
    final c = PulseController.restore(
      level: ank02(),
      actions: const [ToggleSignal('Z'), null],
    );
    addTearDown(c.dispose);
    expect(c.pulses, 0);
    expect(c.history, isEmpty);
  });

  test('a saved run that already ended starts the level fresh', () {
    for (final (level, actions) in [
      (jamLevel(), const <ControlAction?>[null]),
      (ank01(), const <ControlAction?>[null, ToggleSwitch('B')]),
    ]) {
      final c = PulseController.restore(level: level, actions: actions);
      addTearDown(c.dispose);
      expect(c.pulses, 0, reason: level.id);
      expect(c.isLost || c.isSolved, isFalse, reason: level.id);
      expect(c.history, isEmpty, reason: level.id);
    }
  });
}
