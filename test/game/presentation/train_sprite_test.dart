import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/board/train_sprite.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';

import '../../support/graph_builders.dart';

void main() {
  test('heading follows screen direction', () {
    expect(headingOf(Offset.zero, const Offset(10, 0)), 0);
    expect(
      headingOf(Offset.zero, const Offset(0, 10)),
      closeTo(math.pi / 2, 1e-9),
    );
    expect(
      headingOf(Offset.zero, const Offset(-10, 0)),
      closeTo(math.pi, 1e-9),
    );
  });

  testWidgets('the car shows its symbol upright and turns along its edge', (
    tester,
  ) async {
    final level = ank02();
    final controller = PulseController(level: level);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BoardView(controller: controller)),
      ),
    );

    final sprite = find.byType(TrainSprite);
    expect(
      find.descendant(of: sprite, matching: find.text('●')),
      findsOneWidget,
    );

    controller.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final a = level.nodes['A']!.position;
    final b = level.nodes['B']!.position;
    final expected = math.atan2(b.y - a.y, b.x - a.x);
    expect(tester.widget<TrainSprite>(sprite).heading, closeTo(expected, 1e-6));
    expect(tester.widget<TrainSprite>(sprite).headlights, 1);

    await tester.pumpAndSettle();
    expect(tester.widget<TrainSprite>(sprite).heading, closeTo(expected, 1e-6));
    expect(tester.widget<TrainSprite>(sprite).headlights, lessThan(1));
  });

  testWidgets('after undo or restart the car faces the way its state says', (
    tester,
  ) async {
    // ANK-01: A (depot) -> B (switch) -> C (goal, up-right).
    final level = ank01();
    final controller = PulseController(level: level);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BoardView(controller: controller)),
      ),
    );
    double heading() =>
        tester.widget<TrainSprite>(find.byType(TrainSprite)).heading;
    double angle(String from, String to) {
      final a = level.nodes[from]!.position;
      final b = level.nodes[to]!.position;
      return math.atan2(b.y - a.y, b.x - a.x);
    }

    final atStart = heading();
    expect(atStart, closeTo(angle('A', 'B'), 1e-6));

    controller.advance();
    await tester.pumpAndSettle();
    controller.tapNode('B');
    controller.advance();
    await tester.pump(const Duration(milliseconds: 100));
    expect(heading(), closeTo(angle('B', 'C'), 1e-6));
    await tester.pumpAndSettle();

    controller.undo();
    await tester.pump();
    expect(heading(), closeTo(angle('A', 'B'), 1e-6), reason: 'undo');

    controller.restart();
    await tester.pump();
    expect(heading(), closeTo(atStart, 1e-6), reason: 'restart');
  });
}
