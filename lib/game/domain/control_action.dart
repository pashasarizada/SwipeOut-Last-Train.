/// The one control a player may change before a pulse. `null` means wait.
sealed class ControlAction {
  const ControlAction(this.nodeId);

  final String nodeId;
}

final class ToggleSwitch extends ControlAction {
  const ToggleSwitch(super.nodeId);

  @override
  bool operator ==(Object other) =>
      other is ToggleSwitch && other.nodeId == nodeId;

  @override
  int get hashCode => Object.hash('switch', nodeId);

  @override
  String toString() => 'ToggleSwitch($nodeId)';
}

final class ToggleSignal extends ControlAction {
  const ToggleSignal(super.nodeId);

  @override
  bool operator ==(Object other) =>
      other is ToggleSignal && other.nodeId == nodeId;

  @override
  int get hashCode => Object.hash('signal', nodeId);

  @override
  String toString() => 'ToggleSignal($nodeId)';
}
