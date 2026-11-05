import 'package:flutter/material.dart';

import 'game/presentation/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

class SwipeOutApp extends StatelessWidget {
  const SwipeOutApp({super.key, required this.home, this.locale});

  final Widget home;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}
