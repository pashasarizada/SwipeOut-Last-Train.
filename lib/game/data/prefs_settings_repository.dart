import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/game_settings.dart';
import 'settings_repository.dart';

/// Settings as one JSON document in `shared_preferences`; anything missing
/// or unreadable falls back to its default.
final class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository(this.prefs);

  static const String key = 'settings.v1';

  final SharedPreferences prefs;

  static Future<PrefsSettingsRepository> open() async =>
      PrefsSettingsRepository(await SharedPreferences.getInstance());

  @override
  Future<GameSettings> load() async {
    try {
      final raw = prefs.getString(key);
      final json = raw == null ? null : jsonDecode(raw);
      if (json is! Map<String, Object?>) return const GameSettings();
      const defaults = GameSettings();
      return GameSettings(
        vibration: json['vibration'] is bool
            ? json['vibration']! as bool
            : defaults.vibration,
        sound: json['sound'] is bool ? json['sound']! as bool : defaults.sound,
        reducedMotion: json['reducedMotion'] is bool
            ? json['reducedMotion']! as bool
            : defaults.reducedMotion,
        language:
            GameLanguage.values.asNameMap()[json['language']] ??
            defaults.language,
      );
    } on Object {
      return const GameSettings();
    }
  }

  @override
  Future<void> save(GameSettings settings) => prefs.setString(
    key,
    jsonEncode({
      'vibration': settings.vibration,
      'sound': settings.sound,
      'reducedMotion': settings.reducedMotion,
      'language': settings.language.name,
    }),
  );
}
