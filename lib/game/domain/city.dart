/// The five worlds in their fixed order, easiest first.
enum CityId {
  ankara(1),
  baku(2),
  paris(3),
  london(4),
  moscow(5);

  const CityId(this.difficulty);

  /// 1–5 stars shown on the city card.
  final int difficulty;
}
