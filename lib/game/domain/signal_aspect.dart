/// A red signal holds the train standing on its node.
enum SignalAspect {
  red,
  green;

  SignalAspect get toggled =>
      this == SignalAspect.red ? SignalAspect.green : SignalAspect.red;
}
