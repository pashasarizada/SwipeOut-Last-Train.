import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/board/train_sprite.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/kit/motion_settings.dart';

import '../../support/graph_builders.dart';

/// Records haptic feedback types in call order.
List<String> _recordHaptics(WidgetTester tester) {
  final haptics = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add('${call.arguments}'.split('.').last);
      }
      return null;
    },
  );
  return haptics;
}

Future<PulseController> _pump(
  WidgetTester tester,
  LevelDefinition level, {
  bool reduced = false,
}) async {
  final controller = PulseController(level: level);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: MotionSettings(
        reduced: reduced,
        child: Scaffold(body: BoardView(controller: controller)),
      ),
    ),
  );
  return controller;
}

Offset _nodeCenter(WidgetTester tester, LevelDefinition level, String id) {
  final board = find.byType(BoardView);
  final layout = BoardLayout(size: tester.getSize(board));
  return tester.getTopLeft(board) + layout.toScreen(level.nodes[id]!.position);
}

Offset _train(WidgetTester tester) =>
    tester.getCenter(find.byType(TrainSprite));

double _shake(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(BoardView.shakeKey))
    .transform
    .getTranslation()
    .x;

/// wrongWayLevel: after one pulse the train waits at J, pointed at the
/// wrong goal G; the next plain pulse is rejected at G.
Future<PulseController> _armWrongGoal(
  WidgetTester tester, {
  bool reduced = false,
}) async {
  final c = await _pump(tester, wrongWayLevel(), reduced: reduced);
  c.advance();
  await tester.pumpAndSettle();
  return c;
}

void main() {
  testWidgets('a rejected pulse bounces the train towards the conflict and '
      'back, leaving the state untouched', (tester) async {
    final level = wrongWayLevel();
    final c = await _armWrongGoal(tester);
    final start = _train(tester);
    final goal = _nodeCenter(tester, level, 'G');
    final reach = (goal - start).distance;

    c.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final peak = _train(tester);
    expect((goal - peak).distance, lessThan(reach * 0.75));
    expect((goal - peak).distance, greaterThan(reach * 0.6));

    await tester.pumpAndSettle();
    expect(_train(tester), start);
    expect(c.pulses, 1);
    expect(c.isAnimating, isFalse);
  });

  testWidgets('the board shakes on a crash and settles still', (tester) async {
    final c = await _armWrongGoal(tester);
    expect(_shake(tester), 0);

    c.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(_shake(tester).abs(), greaterThan(1));
    expect(_shake(tester).abs(), lessThanOrEqualTo(6));

    await tester.pumpAndSettle();
    expect(_shake(tester), 0);
  });

  testWidgets('reduced motion skips the shake and the bounce', (tester) async {
    final c = await _armWrongGoal(tester, reduced: true);
    final start = _train(tester);

    c.advance();
    for (var ms = 0; ms <= 300; ms += 30) {
      await tester.pump(const Duration(milliseconds: 30));
      expect(_shake(tester), 0);
      expect(_train(tester), start);
    }
  });

  testWidgets('a crash thuds once', (tester) async {
    final haptics = _recordHaptics(tester);
    final c = await _armWrongGoal(tester);
    haptics.clear();
    c.advance();
    await tester.pumpAndSettle();
    expect(haptics, ['heavyImpact']);
  });

  testWidgets('a delivery taps twice', (tester) async {
    final haptics = _recordHaptics(tester);
    final d = await _pump(tester, ank01());
    d.advance();
    await tester.pumpAndSettle();
    haptics.clear();
    d.tapNode('B');
    d.advance();
    await tester.pumpAndSettle();
    expect(haptics, ['lightImpact', 'lightImpact']);
  });
}
