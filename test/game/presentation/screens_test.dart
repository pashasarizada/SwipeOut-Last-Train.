import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/game/progress_store.dart';
import 'package:swipeout_last_train/game/presentation/screens/city_map_screen.dart';
import 'package:swipeout_last_train/game/presentation/screens/home_screen.dart';
import 'package:swipeout_last_train/game/presentation/screens/pulse_game_screen.dart';
import 'package:swipeout_last_train/game/presentation/screens/tunnel_intro_screen.dart';
import 'package:swipeout_last_train/game/presentation/widgets/outcome_board.dart';

import '../../support/graph_builders.dart';
import '../../support/memory_progress_repository.dart';

Future<ProgressStore> _app(
  WidgetTester tester, {
  Widget home = const HomeScreen(),
  Map<CityId, List<LevelDefinition>>? catalog,
  Progress progress = const Progress(),
  Locale? locale,
}) async {
  // Ambient city effects loop for ever; Reduced Motion stops them so the
  // tests can settle (the game honours the platform setting).
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final store = ProgressStore(
    catalog:
        catalog ??
        {
          CityId.ankara: [ank01(), ank02()],
        },
    repository: MemoryProgressRepository(progress),
    progress: progress,
  );
  await tester.pumpWidget(
    SwipeOutApp(store: store, locale: locale, home: home),
  );
  await tester.pumpAndSettle();
  return store;
}

Future<void> _tapNode(
  WidgetTester tester,
  LevelDefinition level,
  String id,
) async {
  final board = find.byType(BoardView);
  final layout = BoardLayout(size: tester.getSize(board));
  await tester.tapAt(
    tester.getTopLeft(board) + layout.toScreen(level.nodes[id]!.position),
  );
  await tester.pump();
}

Future<void> _advance(WidgetTester tester) async {
  await tester.tap(find.textContaining('ADVANCE 1 MINUTE'));
  await tester.pumpAndSettle();
}

Future<void> _openLevelFromMap(
  WidgetTester tester,
  String station,
  String title,
) async {
  await tester.tap(find.byKey(ValueKey('station-$station')));
  await tester.pumpAndSettle();
  expect(find.textContaining(title), findsWidgets);
  await tester.tap(find.text('BOARD'));
  await tester.pumpAndSettle();
}

/// 16 nodes in a 4×4 snake: depot, 14 tracks, goal.
LevelDefinition _sixteen() {
  const ids = 'ABCDEFGHIJKLMNOP';
  return buildLevel(
    id: 'BIG-01',
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
  testWidgets('the tunnel intro gives way to the platform on a tap', (
    tester,
  ) async {
    await _app(tester, home: const TunnelIntroScreen(next: HomeScreen()));
    await tester.tapAt(const Offset(200, 300));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('platform → city tickets → Ankara line map → ANK-01', (
    tester,
  ) async {
    await _app(tester);
    await tester.tap(find.text('CHOOSE CITY'));
    await tester.pumpAndSettle();

    expect(find.text('ANKARA'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('ticket-ankara')));
    await tester.pumpAndSettle();
    expect(find.byType(CityMapScreen), findsOneWidget);

    await _openLevelFromMap(tester, 'ANK-01', 'First Departure');
    expect(find.text('ANKARA 01 · First Departure'), findsOneWidget);
  });

  testWidgets('a city without levels is under construction and stays closed', (
    tester,
  ) async {
    await _app(tester);
    await tester.tap(find.text('CHOOSE CITY'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('LINE UNDER CONSTRUCTION'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('ticket-baku')));
    await tester.pumpAndSettle();
    expect(find.byType(CityMapScreen), findsNothing);
  });

  testWidgets('the second station stays locked until the first is solved', (
    tester,
  ) async {
    await _app(tester, home: const CityMapScreen(city: CityId.ankara));
    await tester.tap(find.byKey(const ValueKey('station-ANK-02')));
    await tester.pumpAndSettle();
    expect(find.text('BOARD'), findsNothing);
  });

  testWidgets('playing ANK-01 saves progress and returns to the line map', (
    tester,
  ) async {
    final store = await _app(
      tester,
      home: const CityMapScreen(city: CityId.ankara),
    );
    await _openLevelFromMap(tester, 'ANK-01', 'First Departure');
    expect(find.textContaining('23:50'), findsOneWidget);

    await _advance(tester);
    expect(find.textContaining('23:51'), findsOneWidget);
    expect(store.progress.run!.actions, hasLength(1));

    await _tapNode(tester, ank01(), 'B');
    expect(find.text('Switch B'), findsOneWidget);
    await _advance(tester);

    expect(find.text('LINE CLEARED'), findsOneWidget);
    expect(store.progress.isSolved('ANK-01'), isTrue);
    expect(store.progress.run, isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.byType(OutcomeBoard),
      findsOneWidget,
      reason: 'system back must not dismiss the result',
    );

    await tester.tap(find.text('BACK TO CITY'));
    await tester.pumpAndSettle();
    expect(find.byType(CityMapScreen), findsOneWidget);
    expect(find.byType(PulseGameScreen), findsNothing);
  });

  testWidgets('continue reopens the half-played level through its city map', (
    tester,
  ) async {
    final store = await _app(tester);
    await store.saveRun('ANK-01', const [null]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1/5 PULSE'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byType(CityMapScreen), findsOneWidget);
  });

  testWidgets('a rejected pulse is announced on the platform', (tester) async {
    await _app(tester, home: PulseGameScreen(level: wrongWayLevel()));
    await _advance(tester);
    await tester.tap(find.textContaining('ADVANCE 1 MINUTE'));
    await tester.pump();
    expect(
      find.text('Wrong line: that stop belongs to another train.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('a jam ends on the result board, and undo goes back', (
    tester,
  ) async {
    await _app(tester, home: PulseGameScreen(level: jamLevel()));
    await _advance(tester);
    expect(find.text('THE LINE IS JAMMED'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(OutcomeBoard),
        matching: find.text('UNDO'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('0/10 PULSE'), findsOneWidget);
  });

  testWidgets('Turkish labels', (tester) async {
    await _app(
      tester,
      home: PulseGameScreen(level: ank01()),
      locale: const Locale('tr'),
    );
    expect(find.textContaining('1 DAKİKA İLERLET'), findsOneWidget);
    expect(find.text('GERİ AL'), findsOneWidget);
    expect(
      find.text('Trenler her dakikada bir durak ilerler.'),
      findsOneWidget,
    );
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('a 16-node board stays playable at 320×568, text ×$scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final level = _sixteen();
      final handle = tester.ensureSemantics();

      await _app(
        tester,
        home: PulseGameScreen(level: level),
        catalog: {
          CityId.ankara: [level],
        },
      );
      expect(tester.takeException(), isNull);

      final layout = BoardLayout(size: tester.getSize(find.byType(BoardView)));
      var nearest = double.infinity;
      final points = [
        for (final n in level.nodes.values) layout.toScreen(n.position),
      ];
      for (final a in points) {
        for (final b in points) {
          if (a != b) nearest = math.min(nearest, (a - b).distance);
        }
      }
      expect(nearest, greaterThanOrEqualTo(44));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });
  }
}
