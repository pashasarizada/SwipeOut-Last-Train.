import '../../domain/direction.dart';

/// Minimum drag length (logical px) that counts as a swipe.
const double kMinSwipeDistance = 24;

/// Maps a drag delta to a direction using its dominant axis.
/// Returns null for drags shorter than [minDistance].
Direction? directionFromDelta(
  double dx,
  double dy, {
  double minDistance = kMinSwipeDistance,
}) {
  if (dx * dx + dy * dy < minDistance * minDistance) return null;
  if (dx.abs() >= dy.abs()) return dx > 0 ? Direction.east : Direction.west;
  return dy > 0 ? Direction.south : Direction.north;
}
