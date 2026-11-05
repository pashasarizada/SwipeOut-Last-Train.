import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/asset_level_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads every indexed level in number order', () async {
    final levels = await AssetLevelRepository(rootBundle).loadAll();

    expect(levels.take(3).map((l) => l.number), [1, 2, 3]);
    expect(levels.first.id, 'istanbul_001');
  });
}
