import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/level_result.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';
import 'package:swipeout_last_train/game/presentation/game/progress_store.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_icon.dart';
import 'package:swipeout_last_train/game/presentation/widgets/outcome_board.dart';
import 'package:swipeout_last_train/game/presentation/widgets/pulse_hud.dart';

import '../../support/all_levels.dart';
import '../../support/memory_progress_repository.dart';

/// The playtest's top finding: players could not tell what earns the
/// third star, nor that a hint costs it. Both are now written out.
Future<void> _pump(WidgetTester tester, Widget home, LevelDefinition level) =>
    tester.pumpWidget(
      SwipeOutApp(
        locale: const Locale('tr'),
        store: ProgressStore(
          catalog: {
            CityId.baku: [level],
          },
          repository: MemoryProgressRepository(),
          progress: const Progress(),
        ),
        home: Scaffold(body: home),
      ),
    );

void main() {
  final levels = allLevels();
  final baku02 = levels.firstWhere((l) => l.id == 'BAK-02');
  final ankara01 = levels.firstWhere((l) => l.id == 'ANK-01');

  testWidgets('the departure board names the three-star target', (
    tester,
  ) async {
    final controller = PulseController(level: baku02);
    addTearDown(controller.dispose);
    await _pump(tester, PulseHud(controller: controller), baku02);
    await tester.pumpAndSettle();
    expect(find.textContaining('3 YILDIZ ≤ 5 DK'), findsOneWidget);

    controller.markHintUsed();
    await tester.pumpAndSettle();
    expect(find.textContaining('3 YILDIZ'), findsNothing);
    expect(find.textContaining('İPUCU: EN ÇOK 2 YILDIZ'), findsOneWidget);
  });

  testWidgets('tutorial levels promise no stars', (tester) async {
    final controller = PulseController(level: ankara01);
    addTearDown(controller.dispose);
    await _pump(tester, PulseHud(controller: controller), ankara01);
    await tester.pumpAndSettle();
    expect(find.textContaining('YILDIZ'), findsNothing);
  });

  OutcomeBoard board(StarRating rating, {bool hintUsed = false}) =>
      OutcomeBoard(
        title: 'HAT TEMİZ',
        actions: const [],
        result: LevelResult(levelId: 'BAK-02', pulses: 7, rating: rating),
        goldTarget: 5,
        hintUsed: hintUsed,
      );

  testWidgets('a missed third star says what it takes', (tester) async {
    await _pump(tester, board(StarRating.silver), baku02);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('3 yıldız için en fazla 5 dakika'), findsOneWidget);
  });

  testWidgets('a hint-capped run says why', (tester) async {
    await _pump(tester, board(StarRating.silver, hintUsed: true), baku02);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('İpucu kullanıldı: en fazla 2 yıldız'), findsOneWidget);
  });

  testWidgets('a gold run needs no explanation', (tester) async {
    await _pump(tester, board(StarRating.gold), baku02);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('3 yıldız için'), findsNothing);
    expect(find.textContaining('İpucu kullanıldı'), findsNothing);
  });

  testWidgets('a hidden rules card shows the board can bring it back', (
    tester,
  ) async {
    final controller = PulseController(level: baku02);
    addTearDown(controller.dispose);
    bool infoShown() => tester
        .widgetList<GameIcon>(find.byType(GameIcon))
        .any((i) => i.kind == GameIconKind.info);

    await _pump(
      tester,
      PulseHud(controller: controller, onBoardTap: () {}, rulesHidden: true),
      baku02,
    );
    await tester.pumpAndSettle();
    expect(infoShown(), isTrue);

    await _pump(
      tester,
      PulseHud(controller: controller, onBoardTap: () {}),
      baku02,
    );
    await tester.pumpAndSettle();
    expect(infoShown(), isFalse);
  });
}
