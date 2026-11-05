import 'package:flutter/widgets.dart';

import 'progress_store.dart';

/// Makes the [ProgressStore] available below the app root. Injected once at
/// the composition root; screens read it, they never create it.
final class GameScope extends InheritedNotifier<ProgressStore> {
  const GameScope({
    super.key,
    required ProgressStore store,
    required super.child,
  }) : super(notifier: store);

  static ProgressStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;
}
