/// An undirected track between two nodes; crossing it takes one pulse.
final class Edge {
  const Edge({required this.id, required this.a, required this.b});

  final String id;
  final String a;
  final String b;

  bool touches(String nodeId) => a == nodeId || b == nodeId;

  String other(String nodeId) => nodeId == a ? b : a;
}
