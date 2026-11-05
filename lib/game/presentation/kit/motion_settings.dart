import 'package:flutter/widgets.dart';

/// Reduced Motion switch for the whole game. Defaults to the platform's
/// "reduce motion" accessibility setting.
final class MotionSettings extends InheritedWidget {
  const MotionSettings({
    super.key,
    required this.reduced,
    required super.child,
  });

  final bool reduced;

  static bool reducedOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionSettings>()?.reduced ??
      MediaQuery.maybeDisableAnimationsOf(context) ??
      false;

  @override
  bool updateShouldNotify(MotionSettings old) => old.reduced != reduced;
}
