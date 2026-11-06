import 'package:flutter/widgets.dart';

import '../game/settings_store.dart';

/// The game's sounds (docs/UI_UX_GUIDELINES.md §9), all synthesised by
/// `tool/make_sounds.py`.
enum SoundCue {
  switchClack('switch_clack'),
  pulseTick('pulse_tick'),
  delivery('delivery'),
  crash('crash'),
  levelWon('level_won'),
  stamp('stamp');

  const SoundCue(this.file);

  /// The file name under `assets/sounds/`, without `.wav`.
  final String file;
}

/// Plays short sound effects; the app gives the real one, tests a fake.
abstract interface class GameSounds {
  void play(SoundCue cue);

  void dispose();
}

/// No sound at all: the default where none is provided.
final class SilentGameSounds implements GameSounds {
  const SilentGameSounds();

  @override
  void play(SoundCue cue) {}

  @override
  void dispose() {}
}

/// Hands the [GameSounds] down the tree.
final class SoundScope extends InheritedWidget {
  const SoundScope({super.key, required this.sounds, required super.child});

  final GameSounds sounds;

  static GameSounds? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SoundScope>()?.sounds;

  @override
  bool updateShouldNotify(SoundScope old) => old.sounds != sounds;
}

/// The one way the game makes a sound, so the Settings switch silences all
/// of it; the game reads fully without sound.
abstract final class GameSound {
  static bool enabled(BuildContext context) =>
      SettingsScope.read(context)?.settings.sound ?? true;

  static void play(BuildContext context, SoundCue cue) {
    if (!enabled(context)) return;
    SoundScope.maybeOf(context)?.play(cue);
  }
}
