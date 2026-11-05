import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/presentation/city/city_theme.dart';
import 'package:swipeout_last_train/game/presentation/kit/advance_lever.dart';
import 'package:swipeout_last_train/game/presentation/kit/control_ticket.dart';
import 'package:swipeout_last_train/game/presentation/kit/departure_board.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_button.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_icon.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_scaffold.dart';
import 'package:swipeout_last_train/game/presentation/kit/motion_settings.dart';
import 'package:swipeout_last_train/game/presentation/kit/platform_announcement.dart';
import 'package:swipeout_last_train/game/presentation/kit/signal_back_button.dart';
import 'package:swipeout_last_train/game/presentation/kit/split_flap_text.dart';
import 'package:swipeout_last_train/game/presentation/kit/track_loader.dart';

Future<void> _pump(WidgetTester tester, Widget child, {bool reduced = false}) =>
    tester.pumpWidget(
      MaterialApp(
        home: MotionSettings(
          reduced: reduced,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

/// Records HapticFeedback calls sent to the platform.
List<String> _hapticLog(WidgetTester tester) {
  final log = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') log.add('${call.arguments}');
      return null;
    },
  );
  return log;
}

void main() {
  group('GameButton', () {
    testWidgets('presses down, fires once and clicks', (tester) async {
      final haptics = _hapticLog(tester);
      var taps = 0;
      await _pump(
        tester,
        GameButton(label: 'DEVAM ET', onPressed: () => taps++),
      );
      final label = find.text('DEVAM ET');
      final rest = tester.getTopLeft(label);

      final gesture = await tester.startGesture(tester.getCenter(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(label).dy - rest.dy, closeTo(3, 0.01));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.getTopLeft(label), rest);
      expect(haptics, contains('HapticFeedbackType.selectionClick'));
    });

    testWidgets('the shadow never changes while pressing (no negative blur)', (
      tester,
    ) async {
      await _pump(tester, GameButton(label: 'GO', onPressed: () {}));
      List<BoxShadow>? shadows() =>
          (tester.widget<Container>(find.byKey(GameButton.faceKey)).decoration!
                  as BoxDecoration)
              .boxShadow;
      final rest = shadows();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('GO')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(shadows(), rest);
      await gesture.up();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      expect(shadows(), rest);
    });

    testWidgets('a disabled button ignores taps', (tester) async {
      await _pump(tester, const GameButton(label: 'X'));
      await tester.tap(find.byType(GameButton), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('never smaller than a 44 pt touch target and no ink', (
      tester,
    ) async {
      await _pump(
        tester,
        GameButton(label: 'OK', size: GameButtonSize.small, onPressed: () {}),
      );
      final size = tester.getSize(find.byType(GameButton));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('SplitFlapText', () {
    testWidgets('flips into the final text', (tester) async {
      await _pump(tester, const SplitFlapText('HAT TEMİZ'));
      expect(find.text('HAT TEMİZ'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('HAT TEMİZ'), findsOneWidget);
    });

    testWidgets('shows the text at once with reduced motion', (tester) async {
      await _pump(tester, const SplitFlapText('23:54'), reduced: true);
      expect(find.text('23:54'), findsOneWidget);
    });
  });

  group('ControlTicket', () {
    testWidgets('tearing by swipe or by the 44 pt cross cancels', (
      tester,
    ) async {
      var torn = 0;
      await _pump(
        tester,
        ControlTicket(label: 'Makas B', onTear: () => torn++),
      );

      await tester.drag(find.byType(ControlTicket), const Offset(-60, 0));
      await tester.pumpAndSettle();
      expect(torn, 1);

      final cross = find.byKey(ControlTicket.tearKey);
      expect(tester.getSize(cross).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(cross).height, greaterThanOrEqualTo(44));
      await tester.tap(cross);
      await tester.pumpAndSettle();
      expect(torn, 2);
    });

    testWidgets('a signal ticket shows the signal icon, a switch the route', (
      tester,
    ) async {
      await _pump(
        tester,
        ControlTicket(
          label: 'Sinyal G',
          icon: GameIconKind.signal,
          onTear: () {},
        ),
      );
      expect(
        tester.widgetList<GameIcon>(find.byType(GameIcon)).map((i) => i.kind),
        contains(GameIconKind.signal),
      );
    });
  });

  testWidgets('SignalBackButton leaves the screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: GameButton(
                  label: 'GO',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: SignalBackButton()),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('GO'));
    await tester.pumpAndSettle();
    expect(find.byType(SignalBackButton), findsOneWidget);
    expect(
      tester.getSize(find.byType(SignalBackButton)).width,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byType(SignalBackButton), findsNothing);
  });

  testWidgets('AdvanceLever is the biggest control and thumps', (tester) async {
    final haptics = _hapticLog(tester);
    var pulses = 0;
    await _pump(
      tester,
      AdvanceLever(label: '1 DAKİKA İLERLET', onPressed: () => pulses++),
    );

    expect(
      tester.getSize(find.byType(AdvanceLever)).height,
      greaterThanOrEqualTo(72),
    );
    await tester.tap(find.text('1 DAKİKA İLERLET'));
    await tester.pumpAndSettle();
    expect(pulses, 1);
    expect(haptics, contains('HapticFeedbackType.mediumImpact'));
  });

  testWidgets('DepartureBoard shows every line on the board font', (
    tester,
  ) async {
    await _pump(
      tester,
      const DepartureBoard(lines: ['ANKARA 01', '23:51 · 1/5 PULSE']),
    );
    await tester.pumpAndSettle();
    expect(find.text('ANKARA 01'), findsOneWidget);
    expect(find.text('23:51 · 1/5 PULSE'), findsOneWidget);
  });

  testWidgets('PlatformAnnouncement slides in and settles', (tester) async {
    await _pump(
      tester,
      const PlatformAnnouncement(message: 'İki tren aynı durakta karşılaştı.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('İki tren aynı durakta karşılaştı.'), findsOneWidget);
  });

  testWidgets('TrackLoader runs, but not with reduced motion', (tester) async {
    await _pump(tester, const TrackLoader());
    expect(tester.binding.hasScheduledFrame, isTrue);

    await _pump(tester, const TrackLoader(), reduced: true);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('GameScaffold paints the city background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GameScaffold(
          city: CityId.baku,
          backdrop: false,
          body: Text('peron'),
        ),
      ),
    );
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, CityTheme.of(CityId.baku).background);
    expect(find.text('peron'), findsOneWidget);
  });
}
