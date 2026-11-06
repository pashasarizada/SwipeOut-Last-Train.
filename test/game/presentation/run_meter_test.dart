import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/train_def.dart';
import 'package:swipeout_last_train/game/presentation/widgets/run_meter.dart';

Future<void> _pump(WidgetTester tester, RunMeter meter) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: meter)),
  ),
);

void main() {
  test(
    'one dot per minute, the used ones filled, stars after par and par+2',
    () {
      final slots = RunMeter.slotsFor(used: 3, max: 8, par: 4);
      final dots = slots.whereType<MeterDot>().toList();
      expect(dots, hasLength(8));
      expect(dots.where((d) => d.used), hasLength(3));
      // ●●●○ ★ ○○ ★ ○○
      expect(slots[4], isA<MeterStar>());
      expect(slots[7], isA<MeterStar>());
      expect(slots.whereType<MeterStar>(), hasLength(2));
    },
  );

  test('no star marks without a par (tutorials) or past the limit', () {
    expect(
      RunMeter.slotsFor(used: 0, max: 5, par: null).whereType<MeterStar>(),
      isEmpty,
    );
    // par+2 == max: only the par mark fits inside the row.
    expect(
      RunMeter.slotsFor(used: 0, max: 6, par: 4).whereType<MeterStar>(),
      hasLength(1),
    );
  });

  test('long runs switch to a bar', () {
    expect(RunMeter.usesBar(max: RunMeter.dotLimit), isFalse);
    expect(RunMeter.usesBar(max: RunMeter.dotLimit + 1), isTrue);
  });

  testWidgets('it speaks its counts and paints no text', (tester) async {
    await _pump(
      tester,
      const RunMeter(
        trains: [
          TrainMark(style: TrainStyle.coral, delivered: true),
          TrainMark(style: TrainStyle.azure, delivered: false),
        ],
        used: 2,
        max: 7,
        par: 5,
        semanticsLabel: '2/7 MIN · 1/2 TRAINS',
      ),
    );
    expect(find.bySemanticsLabel('2/7 MIN · 1/2 TRAINS'), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('a 14-minute run fits a 320 pt wide screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pump(
      tester,
      RunMeter(
        trains: List.filled(
          4,
          const TrainMark(style: TrainStyle.lime, delivered: false),
        ),
        used: 0,
        max: 14,
        par: 13,
        semanticsLabel: '0/14',
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
