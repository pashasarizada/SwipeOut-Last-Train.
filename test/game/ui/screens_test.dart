import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/ui/board/train_token.dart';
import 'package:swipeout_last_train/game/ui/screens/game_screen.dart';
import 'package:swipeout_last_train/game/ui/screens/home_screen.dart';

import '../../support/fake_level_repository.dart';
import '../../support/level_builders.dart';

Future<void> _pumpGame(
  WidgetTester tester,
  LevelDefinition level, {
  Locale? locale,
}) async {
  await tester.pumpWidget(
    SwipeOutApp(
      locale: locale,
      home: GameScreen(level: level),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _token(String id) =>
    find.byWidgetPredicate((w) => w is TrainToken && w.train.id == id);

Future<void> _swipeTrain(WidgetTester tester, String id, Offset by) async {
  await tester.dragFrom(tester.getCenter(_token(id)), by);
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('home leads to the list of tutorial levels', (tester) async {
    final repository = FakeLevelRepository([
      lineLevel(),
      switchLevel(),
      queueLevel(),
    ]);
    await tester.pumpWidget(
      SwipeOutApp(home: HomeScreen(repository: repository)),
    );

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.text('LEVEL 01'), findsOneWidget);
    expect(find.text('LEVEL 02'), findsOneWidget);
    expect(find.text('LEVEL 03'), findsOneWidget);
  });

  testWidgets('playing level 1 to the end shows three stars', (tester) async {
    await _pumpGame(tester, lineLevel());
    expect(find.text('Moves: 0'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await _swipeTrain(tester, 'r1', const Offset(60, 0));
    }
    await tester.pumpAndSettle();

    expect(find.text('Line cleared!'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_border), findsNothing);
  });

  testWidgets('a blocked move shows a short message', (tester) async {
    await _pumpGame(tester, queueLevel());

    await _swipeTrain(tester, 'r1', const Offset(60, 0));

    expect(find.text('Another train is in the way.'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Another train is in the way.'), findsNothing);
  });

  testWidgets('undo returns the train and the move count', (tester) async {
    await _pumpGame(tester, lineLevel());
    await _swipeTrain(tester, 'r1', const Offset(60, 0));
    expect(find.text('Moves: 1'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Moves: 0'), findsOneWidget);
  });

  testWidgets('a 7x7 board fits an iPhone SE screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpGame(tester, bigLevel7x7());

    expect(tester.takeException(), isNull);
    for (final label in ['Undo', 'Restart', 'Hint']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(TrainToken), findsNWidgets(2));
  });

  testWidgets('Turkish locale translates the controls', (tester) async {
    await _pumpGame(tester, lineLevel(), locale: const Locale('tr'));

    expect(find.text('Geri Al'), findsOneWidget);
    expect(find.textContaining('BÖLÜM 01'), findsOneWidget);
  });
}
