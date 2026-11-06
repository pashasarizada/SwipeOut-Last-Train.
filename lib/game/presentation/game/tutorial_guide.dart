import '../../domain/control_action.dart';
import '../../domain/level_definition.dart';

/// Where the tutorial hand points next.
sealed class GuideTarget {
  const GuideTarget();
}

/// Tap this switch or signal (to pick it, or to cancel a wrong pick).
final class GuideNode extends GuideTarget {
  const GuideNode(this.nodeId);

  final String nodeId;

  @override
  bool operator ==(Object other) =>
      other is GuideNode && other.nodeId == nodeId;

  @override
  int get hashCode => nodeId.hashCode;

  @override
  String toString() => 'GuideNode($nodeId)';
}

/// Pull the lever.
final class GuideLever extends GuideTarget {
  const GuideLever();

  @override
  bool operator ==(Object other) => other is GuideLever;

  @override
  int get hashCode => 1;
}

/// The run left the recorded solution: undo.
final class GuideUndo extends GuideTarget {
  const GuideUndo();

  @override
  bool operator ==(Object other) => other is GuideUndo;

  @override
  int get hashCode => 2;
}

/// Follows a tutorial level's recorded solution and names the next tap,
/// so the hand always shows the one right move (pure; no widgets).
abstract final class TutorialGuide {
  static GuideTarget? next({
    required LevelDefinition level,
    required List<ControlAction?> history,
    required ControlAction? pending,
  }) {
    if (!level.tutorial) return null;
    final solution = level.solution;
    for (var i = 0; i < history.length; i++) {
      if (i >= solution.length || history[i] != solution[i]) {
        return const GuideUndo();
      }
    }
    if (history.length >= solution.length) return null;
    final expected = solution[history.length];
    if (pending == expected) return const GuideLever();
    if (pending != null) return GuideNode(pending.nodeId);
    return GuideNode(expected!.nodeId);
  }
}
