import '../domain/city.dart';
import 'json_reader.dart';

/// `assets/levels/index.json`: which level files each city has, in order.
final class LevelIndex {
  LevelIndex(Map<CityId, List<String>> files)
    : _files = Map.unmodifiable({
        for (final MapEntry(:key, :value) in files.entries)
          key: List<String>.unmodifiable(value),
      });

  factory LevelIndex.fromJson(Object? json) {
    const r = JsonReader(fileName);
    final root = r.object(json, 'index');
    return LevelIndex({
      for (final city in r.objects(root, 'cities'))
        r.byName(CityId.values, r.field<String>(city, 'id'), 'city'): [
          for (final file in r.field<List<Object?>>(city, 'levels'))
            file is String ? file : r.fail('level entries must be file names'),
        ],
    });
  }

  static const String assetDir = 'assets/levels';
  static const String fileName = 'index.json';

  static const Map<CityId, String> _prefixes = {
    CityId.ankara: 'ANK-',
    CityId.baku: 'BAK-',
    CityId.paris: 'PAR-',
    CityId.london: 'LON-',
    CityId.moscow: 'MOS-',
  };

  final Map<CityId, List<String>> _files;

  /// Cities in the order they are listed.
  List<CityId> get cities => _files.keys.toList();

  List<String> filesFor(CityId city) => _files[city] ?? const [];

  static String prefixOf(CityId city) => _prefixes[city]!;
}
