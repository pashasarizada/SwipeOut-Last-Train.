import 'norm_point.dart';

/// `junction` is a switch; the JSON format calls it `switch`.
enum NodeKind { depot, track, junction, signal, goal, terminal }

final class Node {
  const Node({
    required this.id,
    required this.kind,
    required this.position,
    this.label,
  });

  final String id;
  final NodeKind kind;
  final NormPoint position;

  /// Thematic station name; shown only when selected or critical.
  final String? label;
}
