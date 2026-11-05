import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'game/data/asset_level_repository.dart';
import 'game/data/level_repository.dart';
import 'game/data/prefs_progress_repository.dart';
import 'game/presentation/game/progress_store.dart';
import 'game/presentation/screens/home_screen.dart';
import 'game/presentation/screens/tunnel_intro_screen.dart';

/// Composition root: concrete dependencies are created only here. Levels and
/// progress load while the dark native launch screen is still showing.
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
  runApp(
    SwipeOutApp(
      store: store,
      home: const TunnelIntroScreen(next: HomeScreen()),
    ),
  );
}
