import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeout_last_train/game/data/prefs_settings_repository.dart';
import 'package:swipeout_last_train/game/domain/game_settings.dart';

Future<PrefsSettingsRepository> _repo([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return PrefsSettingsRepository(await SharedPreferences.getInstance());
}

void main() {
  test('defaults: vibration on, platform motion, system language', () {
    const s = GameSettings();
    expect(
      (s.vibration, s.reducedMotion, s.language),
      (true, false, GameLanguage.system),
    );
  });

  test('settings survive a save and a fresh load', () async {
    final repo = await _repo();
    await repo.save(
      const GameSettings(
        vibration: false,
        sound: false,
        reducedMotion: true,
        language: GameLanguage.tr,
      ),
    );
    final loaded = await (await PrefsSettingsRepository.open()).load();
    expect(
      (loaded.vibration, loaded.sound, loaded.reducedMotion, loaded.language),
      (false, false, true, GameLanguage.tr),
    );
  });

  test('missing or broken settings fall back to the defaults', () async {
    for (final raw in <Object>['{oops', 42, '{"language": "klingon"}']) {
      final loaded = await (await _repo({
        PrefsSettingsRepository.key: raw,
      })).load();
      expect(loaded.vibration, isTrue, reason: '$raw');
      expect(loaded.language, GameLanguage.system, reason: '$raw');
    }
  });
}
