import 'level_json_codec.dart';

/// `assets/levels/index.json`: which level files exist, in play order.
final class LevelIndex {
  const LevelIndex({required this.city, required this.files});

  factory LevelIndex.fromJson(Map<String, Object?> json) {
    final city = json['city'];
    final files = json['levels'];
    if (city is! String || files is! List<Object?>) {
      throw const LevelFormatException('index', 'needs "city" and "levels"');
    }
    return LevelIndex(city: city, files: List<String>.from(files));
  }

  static const String assetDir = 'assets/levels';
  static const String fileName = 'index.json';

  final String city;
  final List<String> files;
}
