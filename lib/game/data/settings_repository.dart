import '../domain/game_settings.dart';

/// Where settings live. Screens depend on this, not on storage (DIP).
abstract interface class SettingsRepository {
  Future<GameSettings> load();
  Future<void> save(GameSettings settings);
}
