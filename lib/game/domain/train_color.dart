/// Train and station colours. [symbol] keeps colour from being the only cue.
enum TrainColor {
  red('R'),
  blue('B'),
  green('G'),
  amber('A');

  const TrainColor(this.symbol);

  final String symbol;
}
