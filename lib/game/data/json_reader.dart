import 'level_format_exception.dart';

/// Typed access to decoded JSON that reports failures against one level id.
final class JsonReader {
  const JsonReader(this.levelId);

  final String levelId;

  Never fail(String message) => throw LevelFormatException(levelId, message);

  T field<T>(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is T) return value;
    fail('"$key" must be a $T, got ${value.runtimeType}');
  }

  T? optional<T>(Map<String, Object?> json, String key) =>
      json[key] == null ? null : field<T>(json, key);

  Map<String, Object?> object(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    fail('$what must be a JSON object');
  }

  /// Objects in the list under [key]; missing optional lists are empty.
  List<Map<String, Object?>> objects(
    Map<String, Object?> json,
    String key, {
    bool required = true,
  }) {
    final list = required
        ? field<List<Object?>>(json, key)
        : optional<List<Object?>>(json, key) ?? const [];
    return [for (final item in list) object(item, '"$key" entry')];
  }

  double number(Map<String, Object?> json, String key) =>
      field<num>(json, key).toDouble();

  T byName<T extends Enum>(List<T> values, String name, String what) =>
      values.firstWhere(
        (v) => v.name == name,
        orElse: () => fail('unknown $what "$name"'),
      );
}
