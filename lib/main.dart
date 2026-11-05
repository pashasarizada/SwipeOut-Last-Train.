import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'l10n/generated/app_localizations.dart';

/// Composition root. Temporary home until the V2 city flow lands (Task 10).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SwipeOutApp(home: _PlaceholderHome()));
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text(AppLocalizations.of(context).appTitle)),
  );
}
