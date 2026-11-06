import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'game/data/asset_level_repository.dart';
import 'game/data/level_repository.dart';
import 'game/data/prefs_progress_repository.dart';
import 'game/data/prefs_settings_repository.dart';
import 'game/presentation/game/progress_store.dart';
import 'game/presentation/game/settings_store.dart';
import 'game/presentation/screens/home_screen.dart';
import 'game/presentation/screens/tunnel_intro_screen.dart';
import 'game/presentation/sound/audio_game_sounds.dart';

/// Composition root: concrete dependencies are created only here. Levels and
/// progress and settings load while the dark launch screen is showing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final catalog = await loadCatalog(AssetLevelRepository(rootBundle));
  final progressRepository = await PrefsProgressRepository.open();
  final store = ProgressStore(
    catalog: catalog,
    repository: progressRepository,
    progress: await progressRepository.load(),
  );
  final settingsRepository = await PrefsSettingsRepository.open();
  final settings = SettingsStore(
    repository: settingsRepository,
    settings: await settingsRepository.load(),
  );
  runApp(
    SwipeOutApp(
      store: store,
      settings: settings,
      sounds: await AudioGameSounds.load(),
      home: const TunnelIntroScreen(next: HomeScreen()),
    ),
  );
}
