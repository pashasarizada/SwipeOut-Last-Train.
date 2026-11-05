import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/asset_level_repository.dart';
import 'package:swipeout_last_train/game/data/level_format_exception.dart';
import 'package:swipeout_last_train/game/domain/city.dart';

final class _MapBundle extends AssetBundle {
  _MapBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final text = files[key];
    if (text == null) throw StateError('missing $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

Matcher _formatErrorMentioning(String text) => throwsA(
  isA<LevelFormatException>().having(
    (e) => e.levelId,
    'levelId',
    contains(text),
  ),
);

String _index(List<Object?> ankara) => jsonEncode({
  'cities': [
    {'id': 'ankara', 'levels': ankara},
    for (final c in ['baku', 'paris', 'london', 'moscow'])
      {'id': c, 'levels': <String>[]},
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads Ankara from the real assets in order', () async {
    final levels = await AssetLevelRepository(
      rootBundle,
    ).loadCity(CityId.ankara);
    expect(levels.map((l) => l.id), [
      'ANK-01',
      'ANK-02',
      'ANK-03',
      'ANK-04',
      'ANK-05',
    ]);
  });

  test('a city without levels yet is empty', () async {
    expect(
      await AssetLevelRepository(rootBundle).loadCity(CityId.baku),
      isEmpty,
    );
  });

  test('broken JSON names the file', () async {
    final bundle = _MapBundle({
      'assets/levels/index.json': _index(['ANK-01.json']),
      'assets/levels/ANK-01.json': '{ not json',
    });
    expect(
      AssetLevelRepository(bundle).loadCity(CityId.ankara),
      _formatErrorMentioning('ANK-01.json'),
    );
  });

  test('a level file whose root is a list names the file', () async {
    final bundle = _MapBundle({
      'assets/levels/index.json': _index(['ANK-01.json']),
      'assets/levels/ANK-01.json': '[]',
    });
    expect(
      AssetLevelRepository(bundle).loadCity(CityId.ankara),
      _formatErrorMentioning('ANK-01.json'),
    );
  });

  test('a non-string index entry is a format error', () async {
    final bundle = _MapBundle({
      'assets/levels/index.json': _index([1]),
    });
    expect(
      AssetLevelRepository(bundle).loadCity(CityId.ankara),
      _formatErrorMentioning('index.json'),
    );
  });
}
