import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../kit/game_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GameFonts.body,
    // No Material ink ripples anywhere (docs/UI_UX_GUIDELINES.md §1).
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentTurquoise,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    // Shared-axis slides everywhere except iOS, which keeps its native
    // swipe-back gesture.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: base.textTheme
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontFamily: GameFonts.display,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontFamily: GameFonts.display,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontFamily: GameFonts.display,
          ),
        ),
  );
}
