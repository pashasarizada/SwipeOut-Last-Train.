/// A level file is structurally malformed. Rule violations of a well-formed
/// file are reported by `LevelValidator` instead.
final class LevelFormatException implements Exception {
  const LevelFormatException(this.levelId, this.message);

  /// Level id, or file name when the id itself cannot be read.
  final String levelId;
  final String message;

  @override
  String toString() => 'LevelFormatException($levelId): $message';
}
