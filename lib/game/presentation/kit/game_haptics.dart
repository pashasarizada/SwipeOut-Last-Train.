import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../game/settings_store.dart';

/// The game's haptic language (docs/UI_UX_GUIDELINES.md §9).
enum HapticKind { selection, light, medium, heavy }

/// The one way the game vibrates, so the Settings switch silences all of
/// it. Without settings in scope (tests, previews) vibration is on.
abstract final class GameHaptics {
  static bool enabled(BuildContext context) =>
      SettingsScope.read(context)?.settings.vibration ?? true;

  static void play(BuildContext context, HapticKind kind) {
    if (!enabled(context)) return;
    switch (kind) {
      case HapticKind.selection:
        HapticFeedback.selectionClick();
      case HapticKind.light:
        HapticFeedback.lightImpact();
      case HapticKind.medium:
        HapticFeedback.mediumImpact();
      case HapticKind.heavy:
        HapticFeedback.heavyImpact();
    }
  }
}
