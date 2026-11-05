import 'star_rating.dart';

final class LevelResult {
  const LevelResult({
    required this.levelId,
    required this.moves,
    required this.rating,
  });

  final String levelId;
  final int moves;
  final StarRating rating;
}
