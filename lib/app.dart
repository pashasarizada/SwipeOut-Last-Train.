import 'package:flutter/material.dart';

import 'game/presentation/game/game_scope.dart';
import 'game/presentation/game/progress_store.dart';
import 'game/presentation/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

class SwipeOutApp extends StatelessWidget {
  const SwipeOutApp({super.key, required this.home, this.locale, this.store});

  final Widget home;
  final Locale? locale;

  /// Catalogue + progress shared by all screens (injected at the root).
  final ProgressStore? store;

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
      builder: (context, child) {
        final store = this.store;
        return store == null ? child! : GameScope(store: store, child: child!);
      },
    );
  }
}
