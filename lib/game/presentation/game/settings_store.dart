import 'package:flutter/widgets.dart';

import '../../data/settings_repository.dart';
import '../../domain/game_settings.dart';

/// The player's settings, shared by every screen and saved on each change.
final class SettingsStore extends ChangeNotifier {
  SettingsStore({
    required SettingsRepository repository,
    required GameSettings settings,
  }) : _repository = repository,
       _settings = settings;

  final SettingsRepository _repository;
  GameSettings _settings;

  GameSettings get settings => _settings;

  /// The locale to force, or null to follow the phone.
  Locale? get locale => switch (_settings.language) {
    GameLanguage.system => null,
    GameLanguage.tr => const Locale('tr'),
    GameLanguage.en => const Locale('en'),
  };

  /// Live at once; a failed write is logged, never thrown.
  Future<void> update(GameSettings next) async {
    if (next == _settings) return;
    _settings = next;
    notifyListeners();
    try {
      await _repository.save(next);
    } on Object catch (error) {
      debugPrint('Settings not saved: $error');
    }
  }
}

/// Makes the [SettingsStore] available below the app root.
final class SettingsScope extends InheritedNotifier<SettingsStore> {
  const SettingsScope({
    super.key,
    required SettingsStore store,
    required super.child,
  }) : super(notifier: store);

  /// The store, or null when the app runs without one (tests, previews).
  static SettingsStore? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()?.notifier;

  /// Reads the store without rebuilding on change (event handlers).
  static SettingsStore? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SettingsScope>()?.notifier;
}
