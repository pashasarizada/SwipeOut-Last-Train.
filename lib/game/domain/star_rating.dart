enum StarRating {
  bronze(1),
  silver(2),
  gold(3);

  const StarRating(this.stars);

  final int stars;

  static const int _silverSlack = 2;

  /// 3 ★ at or under par, 2 ★ up to par+2, otherwise 1 ★ (within the limit).
  static StarRating forPulses({required int pulses, required int par}) {
    if (pulses <= par) return StarRating.gold;
    if (pulses <= par + _silverSlack) return StarRating.silver;
    return StarRating.bronze;
  }
}
