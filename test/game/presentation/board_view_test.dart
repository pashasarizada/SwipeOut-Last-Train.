import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/pulse_forecast.dart';
import 'package:swipeout_last_train/game/domain/pulse_result.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/board/celebration_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/forecast_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/network_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/train_sprite.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/theme/app_colors.dart';
import 'package:swipeout_last_train/game/presentation/theme/motion.dart';

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
    final midway = tester.getCenter(find.byType(TrainSprite));
    expect(midway.dx, greaterThan(a.dx));
    expect(midway.dx, lessThan(b.dx));
    expect(c.isAnimating, isTrue);

    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byType(TrainSprite)), b);
    expect(c.isAnimating, isFalse);
  });

  testWidgets('the goal shows its check mark only after the train arrives', (
    tester,
  ) async {
    final level = ank01();
    final c = await _pump(tester, level);
    NetworkPainter painter() =>
        tester
                .widget<CustomPaint>(
                  find.byWidgetPredicate(
                    (w) => w is CustomPaint && w.painter is NetworkPainter,
                  ),
                )
                .painter!
            as NetworkPainter;

    c.advance();
    await tester.pumpAndSettle();
    c.tapNode('B');
    c.advance();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(painter().goalChecked('C'), isFalse);

    await tester.pumpAndSettle();
    expect(painter().goalChecked('C'), isTrue);
  });

  testWidgets('a 16-node board fits a 320×568 screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, _sixteen());

    expect(tester.takeException(), isNull);
    expect(find.byType(TrainSprite), findsOneWidget);
  });

  testWidgets('the board draws the next pulse as arrows, not while moving', (
    tester,
  ) async {
    final level = ank01();
    final c = await _pump(tester, level);
    ForecastPainter painter() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((p) => p.painter)
        .whereType<ForecastPainter>()
        .firstWhere((p) => p.layer == ForecastLayer.underTrains);

    expect(painter().forecast?.moveOf('red_1')!.to, 'B');
    c.advance();
    await tester.pump();
    expect(painter().forecast, isNull);
    await tester.pumpAndSettle();
    expect(painter().forecast?.moveOf('red_1')!.to, 'D');
    c.tapNode('B');
    await tester.pump();
    expect(painter().forecast?.moveOf('red_1')!.to, 'C');
    // The conflict cross is drawn above the trains.
    final layers = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((p) => p.painter)
        .whereType<ForecastPainter>()
        .map((p) => p.layer);
    expect(layers, [ForecastLayer.underTrains, ForecastLayer.overTrains]);
  });

  test('a moving train gets an arrow, a standing one the waiting badge', () {
    expect(
      ForecastPainter.markOf(const TrainMove(trainId: 'a', from: 'A', to: 'B')),
      ForecastMark.arrow,
    );
    expect(
      ForecastPainter.markOf(const TrainMove(trainId: 'a', from: 'A')),
      ForecastMark.waiting,
    );
  });

  test('the arrow runs along the edge towards the next node', () {
    final level = ank01();
    final layout = BoardLayout(size: const Size(400, 400));
    final painter = ForecastPainter(
      level: level,
      forecast: null,
      layout: layout,
    );
    final (start, end) = painter.arrowFor(
      const TrainMove(trainId: 'red_1', from: 'A', to: 'B'),
    );
    final a = layout.toScreen(level.nodes['A']!.position);
    final b = layout.toScreen(level.nodes['B']!.position);
    expect((start - a).distance, lessThan((end - a).distance));
    expect((end - b).distance, lessThan((start - b).distance));
  });

  test('the open switch arm follows the pending control', () {
    final level = ank01();
    NetworkPainter network(ControlAction? pending) => NetworkPainter(
      level: level,
      state: level.initialState,
      layout: BoardLayout(size: const Size(400, 400)),
      pending: pending,
    );

    // B starts on branch b (towards the terminal D).
    expect(network(null).isOpen('BD'), isTrue);
    expect(network(null).isOpen('BC'), isFalse);
    expect(network(const ToggleSwitch('B')).isOpen('BC'), isTrue);
    expect(network(const ToggleSwitch('B')).isOpen('BD'), isFalse);
    expect(network(null).isOpen('AB'), isTrue, reason: 'trunk is always on');
  });

  test('a waiting train shows why: lit lamp, switch fork or pause', () {
    TrainMove waiting(WaitReason why) =>
        TrainMove(trainId: 'a', from: 'J', waitReason: why);
    expect(
      ForecastPainter.badgeFor(waiting(WaitReason.redSignal)),
      WaitBadge.signalLamp,
    );
    expect(
      ForecastPainter.badgeFor(waiting(WaitReason.switchAgainst)),
      WaitBadge.switchFork,
    );
    expect(
      ForecastPainter.badgeFor(waiting(WaitReason.deadEnd)),
      WaitBadge.pause,
    );
    expect(
      ForecastPainter.badgeFor(
        const TrainMove(trainId: 'a', from: 'J', to: 'G'),
      ),
      isNull,
    );
  });

  test('trains in a conflict turn red and the conflict node is crossed', () {
    final level = wrongWayLevel();
    final painter = ForecastPainter(
      level: level,
      forecast: PulseForecast(
        moves: const [TrainMove(trainId: 'a', from: 'J', to: 'G')],
        conflict: const PulseFailed(
          PulseFailure.wrongGoal,
          trainIds: ['a'],
          nodeId: 'G',
        ),
      ),
      layout: BoardLayout(size: const Size(400, 400)),
    );
    expect(
      painter.colorFor(const TrainMove(trainId: 'a', from: 'J', to: 'G')),
      AppColors.danger,
    );
    expect(painter.crossAt, 'G');
    expect(painter.glowingGoals, isEmpty);
  });

  test('a goal about to receive its train glows', () {
    final level = ank01();
    final painter = ForecastPainter(
      level: level,
      forecast: PulseForecast(
        moves: const [TrainMove(trainId: 'red_1', from: 'B', to: 'C')],
        delivers: const {'red_1'},
      ),
      layout: BoardLayout(size: const Size(400, 400)),
    );
    expect(painter.crossAt, isNull);
    expect(painter.glowingGoals, {'C'});
    expect(
      painter.colorFor(const TrainMove(trainId: 'red_1', from: 'B', to: 'C')),
      isNot(AppColors.danger),
    );
  });

  test('the cross sits in front of a standing train, not on it', () {
    final level = jamLevel();
    final layout = BoardLayout(size: const Size(400, 400));
    final painter = ForecastPainter(
      level: level,
      forecast: PulseForecast(
        moves: const [
          TrainMove(trainId: 'a', from: 'M', to: 'N'),
          TrainMove(trainId: 'b', from: 'N'),
        ],
        conflict: const PulseFailed(
          PulseFailure.blockedByStanding,
          trainIds: ['a', 'b'],
          nodeId: 'N',
        ),
      ),
      layout: layout,
    );
    final n = layout.toScreen(level.nodes['N']!.position);
    final m = layout.toScreen(level.nodes['M']!.position);
    final cross = painter.crossPoint!;
    expect((cross - n).distance, closeTo(ForecastPainter.crossShift, 0.01));
    expect((cross - m).distance, lessThan((n - m).distance));
  });

  testWidgets('a delivery bursts at the goal once the train arrives', (
    tester,
  ) async {
    final c = await _pump(tester, ank01());
    CelebrationPainter? burst() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((p) => p.painter)
        .whereType<CelebrationPainter>()
        .firstOrNull;

    c.advance();
    await tester.pumpAndSettle();
    c.tapNode('B');
    c.advance();
    await tester.pump();
    await tester.pump(kPulseMove + const Duration(milliseconds: 50));
    expect(burst()?.trainIds, ['red_1']);
    expect(burst()!.particleCount, CelebrationPainter.sparks);
    await tester.pumpAndSettle();
  });

  test('two trains home in one minute make a bigger burst', () {
    final level = ank01();
    CelebrationPainter painter(List<String> ids, {bool reduced = false}) =>
        CelebrationPainter(
          level: level,
          trainIds: ids,
          layout: BoardLayout(size: const Size(400, 400)),
          reduced: reduced,
          progress: kAlwaysDismissedAnimation,
        );
    expect(painter(['a', 'b']).particleCount, 2 * CelebrationPainter.sparks);
    expect(painter(['a'], reduced: true).particleCount, 0);
  });
}
