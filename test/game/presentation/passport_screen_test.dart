import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_result.dart';
import 'package:swipeout_last_train/game/domain/passport.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/presentation/kit/motion_settings.dart';
import 'package:swipeout_last_train/game/presentation/passport/passport_page.dart';
import 'package:swipeout_last_train/game/presentation/passport/passport_screen.dart';
import 'package:swipeout_last_train/game/presentation/passport/passport_stamp.dart';

Passport _passport({bool ankaraDone = true}) {
  final ids = {
    for (final c in CityId.values)
      c: [for (var i = 1; i <= 6; i++) '${c.name}-$i'],
  };
  var p = const Progress();
  for (final id in ankaraDone ? ids[CityId.ankara]! : const <String>[]) {
    p = p.withResult(LevelResult(levelId: id, pulses: 1, rating: null));
  }
  return Passport.from(
    Passport.recordStamps(p, ids, DateTime.utc(2026, 11, 5)).$1,
    ids,
  );
}

void main() {
  testWidgets('the passport opens on its cover and pages through the cities', (
    tester,
  ) async {
    await tester.pumpWidget(
      SwipeOutApp(home: PassportScreen(passport: _passport())),
    );
    await tester.pumpAndSettle();
    expect(find.text('METRO PASSPORT'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('ANKARA'), findsOneWidget);
    expect(find.text('Hoş geldin, başkent!'), findsOneWidget);
    expect(find.text('6/6'), findsOneWidget);
  });

  testWidgets('a highlighted city lands its stamp with a thud', (tester) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add('${call.arguments}');
        }
        return null;
      },
    );
    await tester.pumpWidget(
      SwipeOutApp(
        home: PassportScreen(passport: _passport(), highlight: CityId.ankara),
      ),
    );
    await tester.pumpAndSettle();

    final stamp = tester.widget<PassportStamp>(
      find.byWidgetPredicate((w) => w is PassportStamp && w.animateIn),
    );
    expect(stamp.stamp.city, CityId.ankara);
    expect(stamp.animateIn, isTrue);
    expect(haptics, contains('HapticFeedbackType.heavyImpact'));
    expect(find.text('Stamp earned!'), findsOneWidget);
  });

  testWidgets(
    'an unearned stamp shows progress, and reduced motion skips the press',
    (tester) async {
      await tester.pumpWidget(
        SwipeOutApp(
          home: MotionSettings(
            reduced: true,
            child: PassportScreen(
              passport: _passport(ankaraDone: false),
              highlight: CityId.ankara,
            ),
          ),
        ),
      );
      await tester.pump();
      final page = find.byWidgetPredicate(
        (w) => w is PassportPage && w.highlight,
      );
      expect(
        find.descendant(of: page, matching: find.text('0/6')),
        findsOneWidget,
      );
      expect(find.text('Stamp earned!'), findsNothing);
    },
  );
}
