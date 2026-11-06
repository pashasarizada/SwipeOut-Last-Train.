import 'package:flutter/material.dart';

import 'game/presentation/game/game_scope.dart';
import 'game/presentation/game/progress_store.dart';
import 'game/presentation/game/settings_store.dart';
import 'game/presentation/kit/contrast_settings.dart';
import 'game/presentation/kit/motion_settings.dart';
import 'game/presentation/sound/game_sounds.dart';
import 'game/presentation/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

class SwipeOutApp extends StatelessWidget {
  const SwipeOutApp({
    super.key,
    required this.home,
    this.locale,
    this.store,
    this.settings,
    this.sounds,
  });

  final Widget home;

  /// Forces a locale (tests); otherwise [settings] or the phone decides.
  final Locale? locale;

  /// Catalogue + progress shared by all screens (injected at the root).
  final ProgressStore? store;

  /// Player settings shared by all screens (injected at the root).
  final SettingsStore? settings;

  /// Sound effects (the real player in the app, a fake in tests).
  final GameSounds? sounds;

  @override
  Widget build(BuildContext context) {
    final settings = this.settings;
    if (settings == null) return _app(locale);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => _app(locale ?? settings.locale),
    );
  }

  Widget _app(Locale? locale) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
    builder: (context, child) {
      var scoped = child!;
      if (sounds case final sounds?) {
        scoped = SoundScope(sounds: sounds, child: scoped);
      }
      if (store case final store?) {
        scoped = GameScope(store: store, child: scoped);
      }
      if (settings case final settings?) {
        scoped = SettingsScope(
          store: settings,
          child: MotionSettings(
            reduced:
                settings.settings.reducedMotion ||
                (MediaQuery.maybeDisableAnimationsOf(context) ?? false),
            child: ContrastSettings(
              high:
                  settings.settings.highContrast ||
                  (MediaQuery.maybeHighContrastOf(context) ?? false),
              child: scoped,
            ),
          ),
        );
      }
      return scoped;
    },
  );
}
