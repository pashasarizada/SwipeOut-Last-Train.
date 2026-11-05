enum SwitchBranch {
  a,
  b;

  SwitchBranch get toggled =>
      this == SwitchBranch.a ? SwitchBranch.b : SwitchBranch.a;
}

/// A switch joins `trunk` with exactly one of its two branches at a time.
final class SwitchDef {
  const SwitchDef({
    required this.nodeId,
    required this.trunkEdge,
    required this.branchAEdge,
    required this.branchBEdge,
  });

  final String nodeId;
  final String trunkEdge;
  final String branchAEdge;
  final String branchBEdge;

  String edgeFor(SwitchBranch branch) =>
      branch == SwitchBranch.a ? branchAEdge : branchBEdge;
}
