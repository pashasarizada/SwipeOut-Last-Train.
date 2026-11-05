import 'star_rating.dart';

final class LevelResult {
  const LevelResult({
    required this.levelId,
    required this.pulses,
    required this.rating,
  });

  final String levelId;
  final int pulses;

  /// Null for tutorial levels, which award no stars.
  final StarRating? rating;
}
