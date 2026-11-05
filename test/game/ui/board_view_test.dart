import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/board_state.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/engine/level_solver.dart';
import 'package:swipeout_last_train/game/ui/board/board_geometry.dart';
import 'package:swipeout_last_train/game/ui/board/board_painter.dart';
import 'package:swipeout_last_train/game/ui/board/board_view.dart';
import 'package:swipeout_last_train/game/ui/board/train_token.dart';
import 'package:swipeout_last_train/game/ui/game/game_controller.dart';
import 'package:swipeout_last_train/game/ui/theme/motion.dart';

import '../../support/level_builders.dart';

Future<SolverOutcome> _noHint(LevelDefinition _, BoardState _) async =>
    const Unsolvable();

final _board = find.byWidgetPredicate(
  (w) => w is CustomPaint && w.painter is BoardPainter,
);

Future<GameController> _pumpBoard(
  WidgetTester tester,
  LevelDefinition level,
) async {
  final controller = GameController(level: level, hintRunner: _noHint);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: BoardView(controller: controller)),
    ),
  );
  return controller;
}

Offset _cellCenter(WidgetTester tester, LevelDefinition level, GridPos pos) {
  final geometry = BoardGeometry(
    columns: level.width,
    rows: level.height,
    available: tester.getSize(_board),
  );
  return tester.getTopLeft(_board) + geometry.centerOf(pos);
}

void main() {
  testWidgets('tapping a train selects it', (tester) async {
    final level = queueLevel();
    final controller = await _pumpBoard(tester, level);

    await tester.tapAt(_cellCenter(tester, level, const GridPos(1, 2)));
    await tester.pump();

    expect(controller.selectedTrainId, 'b1');
  });

  testWidgets('dragging from a train moves it one cell', (tester) async {
    final level = lineLevel();
    final controller = await _pumpBoard(tester, level);
    final start = _cellCenter(tester, level, const GridPos(0, 2));

    await tester.dragFrom(start, const Offset(60, 0));
    await tester.pumpAndSettle();

    expect(controller.moveCount, 1);
    expect(
      tester.getCenter(find.byType(TrainToken)),
      _cellCenter(tester, level, const GridPos(1, 2)),
    );
  });

  testWidgets('tapping the switch toggles it', (tester) async {
    final level = switchLevel();
    final controller = await _pumpBoard(tester, level);

    await tester.tapAt(_cellCenter(tester, level, const GridPos(2, 2)));
    await tester.pump(kMoveAnimation);

    expect(controller.moveCount, 1);
  });
}
