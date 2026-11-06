import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/board/rail_geometry.dart';
import 'package:swipeout_last_train/game/presentation/board/train_layer.dart';
import 'package:swipeout_last_train/game/presentation/board/train_sprite.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/theme/motion.dart';

import '../../support/graph_builders.dart';

/// Eased pulse progress after [elapsed], as the train layer plays it.
double _t(Duration elapsed) => Curves.easeInOut.transform(
  elapsed.inMicroseconds / kPulseMove.inMicroseconds,
);

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

  testWidgets('the car shows its symbol upright and turns along its rail', (
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

    final g = RailGeometry(
      level,
      BoardLayout(size: tester.getSize(find.byType(BoardView))),
    );
    controller.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final (_, moving) = TrainLayer.placeOnRail(
      level,
      g,
      from: 'A',
      to: 'B',
      t: _t(const Duration(milliseconds: 200)),
    );
    expect(tester.widget<TrainSprite>(sprite).heading, closeTo(moving, 1e-6));
    expect(tester.widget<TrainSprite>(sprite).headlights, 1);

    await tester.pumpAndSettle();
    final rail = g.between('A', 'B');
    expect(
      tester.widget<TrainSprite>(sprite).heading,
      closeTo(rail.headingAt(rail.length), 1e-6),
    );
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
    final g = RailGeometry(
      level,
      BoardLayout(size: tester.getSize(find.byType(BoardView))),
    );
    double arrived(String from, String to) {
      final rail = g.between(from, to);
      return rail.headingAt(rail.length);
    }

    final atStart = heading();
    expect(atStart, closeTo(g.between('A', 'B').headingAt(0), 1e-6));

    controller.advance();
    await tester.pumpAndSettle();
    controller.tapNode('B');
    controller.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final (_, moving) = TrainLayer.placeOnRail(
      level,
      g,
      from: 'B',
      to: 'C',
      t: _t(const Duration(milliseconds: 100)),
    );
    expect(heading(), closeTo(moving, 1e-6));
    await tester.pumpAndSettle();

    controller.undo();
    await tester.pump();
    expect(heading(), closeTo(arrived('A', 'B'), 1e-6), reason: 'undo');

    controller.restart();
    await tester.pump();
    expect(heading(), closeTo(atStart, 1e-6), reason: 'restart');
  });
}
