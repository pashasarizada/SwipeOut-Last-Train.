import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('app renders title on placeholder home', (tester) async {
    await tester.pumpWidget(const SwipeOutApp(home: _TitleProbe()));
    await tester.pumpAndSettle();

    expect(find.text('SwipeOut: Last Train'), findsOneWidget);
  });
}

class _TitleProbe extends StatelessWidget {
  const _TitleProbe();

  @override
  Widget build(BuildContext context) =>
      Text(AppLocalizations.of(context).appTitle);
}
