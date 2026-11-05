import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/board/train_token.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';

import '../../support/graph_builders.dart';

Future<PulseController> _pump(
  WidgetTester tester,
  LevelDefinition level,
) async {
  final controller = PulseController(level: level);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: BoardView(controller: controller)),
    ),
  );
  return controller;
}

Offset _nodeCenter(WidgetTester tester, LevelDefinition level, String id) {
  final board = find.byType(BoardView);
  final layout = BoardLayout(size: tester.getSize(board));
  return tester.getTopLeft(board) + layout.toScreen(level.nodes[id]!.position);
}

/// 16 nodes in a 4×4 snake: depot, 14 tracks, goal.
LevelDefinition _sixteen() {
  const ids = 'ABCDEFGHIJKLMNOP';
  return buildLevel(
    nodes: [
      for (var i = 0; i < 16; i++)
        node(
          ids[i],
          i == 0 ? NodeKind.depot : (i == 15 ? NodeKind.goal : NodeKind.track),
          0.1 + 0.8 * ((i ~/ 4).isEven ? i % 4 : 3 - i % 4) / 3,
          0.1 + 0.8 * (i ~/ 4) / 3,
        ),
    ],
    edges: [for (var i = 0; i < 15; i++) '${ids[i]}${ids[i + 1]}'],
    trains: [trainDef('t', 'A', 'P')],
  );
}

void main() {
  testWidgets('tapping the switch sets it as the pending control', (
    tester,
  ) async {
    final level = ank01();
    final c = await _pump(tester, level);

    await tester.tapAt(_nodeCenter(tester, level, 'B'));
    await tester.pump();

    expect(c.pending, const ToggleSwitch('B'));
  });

  testWidgets('a pulse slides the train along its edge, then unlocks', (
    tester,
  ) async {
    final level = ank01();
    final c = await _pump(tester, level);
    final a = _nodeCenter(tester, level, 'A');
    final b = _nodeCenter(tester, level, 'B');

    c.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final midway = tester.getCenter(find.byType(TrainToken));
    expect(midway.dx, greaterThan(a.dx));
    expect(midway.dx, lessThan(b.dx));
    expect(c.isAnimating, isTrue);

    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byType(TrainToken)), b);
    expect(c.isAnimating, isFalse);
  });

  testWidgets('a 16-node board fits a 320×568 screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, _sixteen());

    expect(tester.takeException(), isNull);
    expect(find.byType(TrainToken), findsOneWidget);
  });
}
