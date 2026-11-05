/// A position normalised to the 0.0–1.0 board square.
final class NormPoint {
  const NormPoint(this.x, this.y);

  final double x;
  final double y;

  bool get isInUnitSquare => x >= 0 && x <= 1 && y >= 0 && y <= 1;
}
