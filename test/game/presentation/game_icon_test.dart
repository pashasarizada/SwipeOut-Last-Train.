import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_icon.dart';

void main() {
  testWidgets('every drawn icon paints at its size and can be labelled', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            for (final kind in GameIconKind.values)
              GameIcon(kind, size: 24, color: const Color(0xFFFFFFFF)),
            const GameIcon(
              GameIconKind.lock,
              color: Color(0xFFFFFFFF),
              semanticLabel: 'Locked',
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(GameIcon).first), const Size.square(24));
    expect(find.bySemanticsLabel('Locked'), findsOneWidget);
  });
}
