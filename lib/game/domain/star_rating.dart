enum StarRating {
  bronze(1),
  silver(2),
  gold(3);

  const StarRating(this.stars);

  final int stars;

  static const int _goldSlack = 1;
  static const int _silverSlack = 4;

  static StarRating forMoves({required int moves, required int optimal}) {
    if (moves <= optimal + _goldSlack) return StarRating.gold;
    if (moves <= optimal + _silverSlack) return StarRating.silver;
    return StarRating.bronze;
  }
}
