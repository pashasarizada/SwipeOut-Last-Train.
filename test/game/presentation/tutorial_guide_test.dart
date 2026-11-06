import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/presentation/game/tutorial_guide.dart';

import '../../support/graph_builders.dart';

void main() {
  // ANK-01: wait, then turn B.  ANK-02: see its fixture.
  final level = ank01();

  test('a wait step points at the lever', () {
    expect(
      TutorialGuide.next(level: level, history: const [], pending: null),
      const GuideLever(),
    );
  });

  test('a control step points at its node, then at the lever', () {
    expect(
      TutorialGuide.next(level: level, history: const [null], pending: null),
      const GuideNode('B'),
    );
    expect(
      TutorialGuide.next(
        level: level,
        history: const [null],
        pending: const ToggleSwitch('B'),
      ),
      const GuideLever(),
    );
  });

  test('a wrong pick points back at it, to cancel', () {
    expect(
      TutorialGuide.next(
        level: level,
        history: const [],
        pending: const ToggleSwitch('B'),
      ),
      const GuideNode('B'),
    );
  });

  test('a run off the recorded solution points at undo', () {
    expect(
      TutorialGuide.next(
        level: level,
        history: const [ToggleSwitch('B')],
        pending: null,
      ),
      const GuideUndo(),
    );
  });

  test('no hand once solved, or on levels that are not tutorials', () {
    expect(
      TutorialGuide.next(
        level: level,
        history: const [null, ToggleSwitch('B')],
        pending: null,
      ),
      isNull,
    );
    expect(
      TutorialGuide.next(
        level: wrongWayLevel(),
        history: const [],
        pending: null,
      ),
      isNull,
    );
  });
}
