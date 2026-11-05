import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'game/data/asset_level_repository.dart';
import 'game/presentation/screens/home_screen.dart';

/// Composition root: concrete dependencies are created only here.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    SwipeOutApp(home: HomeScreen(repository: AssetLevelRepository(rootBundle))),
  );
}
