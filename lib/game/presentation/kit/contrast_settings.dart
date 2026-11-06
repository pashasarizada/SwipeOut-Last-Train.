import 'package:flutter/widgets.dart';

/// High Contrast switch for the whole game (docs/UI_UX_GUIDELINES.md §10):
/// brighter, thicker rails and arrows, a quieter city behind the board.
/// Defaults to the phone's "increase contrast" setting.
final class ContrastSettings extends InheritedWidget {
  const ContrastSettings({super.key, required this.high, required super.child});

  final bool high;

  static bool highOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ContrastSettings>()?.high ??
      MediaQuery.maybeHighContrastOf(context) ??
      false;

  @override
  bool updateShouldNotify(ContrastSettings old) => old.high != high;
}
