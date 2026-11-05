/// Shape drawn on a train and its goal, so colour is never the only cue.
enum TrainSymbol {
  circle('●'),
  triangle('▲'),
  square('■'),
  diamond('◆');

  const TrainSymbol(this.glyph);

  final String glyph;
}

enum TrainStyle { coral, azure, lime, amber }

/// Static description of a train: where it starts and where it must go.
final class TrainDef {
  const TrainDef({
    required this.id,
    required this.startNode,
    required this.goalNode,
    required this.symbol,
    required this.style,
  });

  final String id;
  final String startNode;
  final String goalNode;
  final TrainSymbol symbol;
  final TrainStyle style;
}
