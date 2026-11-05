import 'dart:math' as math;
import 'dart:ui';

import '../../domain/node.dart';
import '../../domain/norm_point.dart';

/// Maps normalised node positions onto a centred square and back.
/// Shared by painting, trains and tap handling.
final class BoardLayout {
  BoardLayout({required this.size, this.padding = 32})
    : side = math.max(0, math.min(size.width, size.height) - 2 * padding);

  final Size size;
  final double padding;
  final double side;

  /// Half of a 44 pt minimum touch target.
  static const double defaultHitRadius = 28;

  Offset get _origin =>
      Offset((size.width - side) / 2, (size.height - side) / 2);

  Offset toScreen(NormPoint p) => _origin + Offset(p.x * side, p.y * side);

  /// The node nearest to [local], if it lies within [hitRadius].
  String? nodeAt(
    Offset local,
    Map<String, Node> nodes, {
    double hitRadius = defaultHitRadius,
  }) {
    String? best;
    var bestDistance = hitRadius;
    for (final node in nodes.values) {
      final d = (toScreen(node.position) - local).distance;
      if (d <= bestDistance) {
        best = node.id;
        bestDistance = d;
      }
    }
    return best;
  }

  @override
  bool operator ==(Object other) =>
      other is BoardLayout && other.size == size && other.padding == padding;

  @override
  int get hashCode => Object.hash(size, padding);
}
