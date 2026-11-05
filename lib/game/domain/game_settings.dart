/// The language the game speaks: the phone's, or one chosen in Settings.
enum GameLanguage { system, tr, en }

/// Player preferences (docs/UI_UX_GUIDELINES.md §8): all local, all optional.
final class GameSettings {
  const GameSettings({
    this.vibration = true,
    this.reducedMotion = false,
    this.language = GameLanguage.system,
  });

  /// Haptic feedback on presses, pulses, crashes and stamps.
  final bool vibration;

  /// Forces Reduced Motion on, whatever the phone's setting.
  final bool reducedMotion;

  final GameLanguage language;

  GameSettings copyWith({
    bool? vibration,
    bool? reducedMotion,
    GameLanguage? language,
  }) => GameSettings(
    vibration: vibration ?? this.vibration,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    language: language ?? this.language,
  );

  @override
  bool operator ==(Object other) =>
      other is GameSettings &&
      other.vibration == vibration &&
      other.reducedMotion == reducedMotion &&
      other.language == language;

  @override
  int get hashCode => Object.hash(vibration, reducedMotion, language);
}
