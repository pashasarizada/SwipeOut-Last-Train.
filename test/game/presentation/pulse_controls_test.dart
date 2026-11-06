import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/presentation/game/progress_store.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/kit/advance_lever.dart';
import 'package:swipeout_last_train/game/presentation/widgets/pulse_controls.dart';

import '../../support/graph_builders.dart';
import '../../support/memory_progress_repository.dart';

Future<PulseController> _pump(
  WidgetTester tester,
  LevelDefinition level,
) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final controller = PulseController(level: level);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    SwipeOutApp(
      locale: const Locale('tr'),
      store: ProgressStore(
        catalog: {
          CityId.ankara: [level],
        },
        repository: MemoryProgressRepository(),
        progress: const Progress(),
      ),
      home: Scaffold(body: PulseControls(controller: controller)),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

AdvanceLever _lever(WidgetTester tester) =>
    tester.widget<AdvanceLever>(find.byType(AdvanceLever));

void main() {
  testWidgets('the lever warns before a pulse that would fail', (tester) async {
    final c = await _pump(tester, wrongWayLevel());
    expect(_lever(tester).warning, isFalse);

    c.advance();
    c.finishAnimation();
    await tester.pumpAndSettle();
    // J still points at the wrong goal G.
    expect(_lever(tester).warning, isTrue);
    expect(_lever(tester).onPressed, isNotNull, reason: 'it may still pull');
    expect(_lever(tester).semanticsLabel, contains('Dikkat'));

    c.tapNode('J');
    await tester.pumpAndSettle();
    expect(_lever(tester).warning, isFalse);
    expect(_lever(tester).semanticsLabel, contains('Makas J'));
  });
}
