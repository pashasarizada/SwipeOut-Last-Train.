import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/screens/city_levels_screen.dart';
import 'package:swipeout_last_train/game/presentation/screens/home_screen.dart';
import 'package:swipeout_last_train/game/presentation/screens/pulse_game_screen.dart';
import 'package:swipeout_last_train/game/presentation/widgets/level_outcome_sheet.dart';

import '../../support/fake_level_repository.dart';
import '../../support/graph_builders.dart';

final _repository = FakeLevelRepository({
  CityId.ankara: [ank01(), ank02()],
});

Future<void> _pumpGame(
  WidgetTester tester,
  LevelDefinition level, {
  Locale? locale,
}) async {
  await tester.pumpWidget(
    SwipeOutApp(
      locale: locale,
      home: PulseGameScreen(level: level),
    ),
  );
  await tester.pumpAndSettle();
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

void main() {
  testWidgets('home → city → Ankara → ANK-01', (tester) async {
    await tester.pumpWidget(
      SwipeOutApp(home: HomeScreen(repository: _repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CHOOSE CITY'));
    await tester.pumpAndSettle();
    expect(find.text('NIGHTMARE NETWORK'), findsOneWidget);

    await tester.tap(find.text('ANKARA'));
    await tester.pumpAndSettle();
    expect(find.byType(CityLevelsScreen), findsOneWidget);

    await tester.tap(find.textContaining('First Departure'));
    await tester.pumpAndSettle();
    expect(find.text('LAST TRAIN · ANKARA 01'), findsOneWidget);
  });

  testWidgets('a city without levels is marked coming soon and stays closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      SwipeOutApp(home: HomeScreen(repository: _repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('CHOOSE CITY'));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsNWidgets(4));
    await tester.tap(find.text('BAKU'));
    await tester.pumpAndSettle();
    expect(find.byType(CityLevelsScreen), findsNothing);
  });

  testWidgets('ANK-01 is played to the end without star pressure', (
    tester,
  ) async {
    final level = ank01();
    await _pumpGame(tester, level);
    expect(find.text('0/5 PULSE · '), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);

    await _advance(tester);
    await _tapNode(tester, level, 'B');
    expect(find.text('Switch B'), findsOneWidget);
    expect(find.text('Control: 0/1'), findsOneWidget);
    await _advance(tester);

    expect(find.text('LINE CLEARED'), findsOneWidget);
    expect(find.text('2 pulses'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
  });

  testWidgets('the delivered counter waits for the train to arrive', (
    tester,
  ) async {
    final level = ank01();
    await _pumpGame(tester, level);
    await _advance(tester);
    await _tapNode(tester, level, 'B');

    await tester.tap(find.textContaining('ADVANCE 1 MINUTE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('0/1'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('a rejected pulse explains itself and costs no pulse', (
    tester,
  ) async {
    await _pumpGame(tester, wrongWayLevel());
    await _advance(tester);

    await tester.tap(find.textContaining('ADVANCE 1 MINUTE'));
    await tester.pump();

    expect(
      find.text('Wrong line: that stop belongs to another train.'),
      findsOneWidget,
    );
    expect(find.textContaining('1/10 PULSE'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('a jam shows the loss sheet with undo', (tester) async {
    await _pumpGame(tester, jamLevel());
    await _advance(tester);

    expect(find.text('The line is jammed'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(LevelOutcomeSheet),
        matching: find.text('Undo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('0/10 PULSE'), findsOneWidget);
  });

  testWidgets('back from the game and from the result sheet', (tester) async {
    await tester.pumpWidget(
      SwipeOutApp(
        home: CityLevelsScreen(city: CityId.ankara, levels: [ank01()]),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('First Departure'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PulseGameScreen), findsNothing);

    await tester.tap(find.textContaining('First Departure'));
    await tester.pumpAndSettle();
    await _advance(tester);
    await _tapNode(tester, ank01(), 'B');
    await _advance(tester);
    await tester.tap(find.text('Back to city'));
    await tester.pumpAndSettle();
    expect(find.byType(PulseGameScreen), findsNothing);
    expect(find.byType(CityLevelsScreen), findsOneWidget);
  });

  testWidgets('Turkish labels', (tester) async {
    await _pumpGame(tester, ank01(), locale: const Locale('tr'));

    expect(find.textContaining('1 DAKİKA İLERLET'), findsOneWidget);
    expect(find.text('Geri Al'), findsOneWidget);
    expect(
      find.text('Trenler her dakikada bir durak ilerler.'),
      findsOneWidget,
    );
  });

  testWidgets('fits a 320×568 screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpGame(tester, ank02(), locale: const Locale('tr'));
    await _tapNode(tester, ank02(), 'B');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('1 DAKİKA İLERLET'), findsOneWidget);
  });
}
