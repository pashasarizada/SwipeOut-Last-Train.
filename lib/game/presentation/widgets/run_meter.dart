import 'package:flutter/widgets.dart';

import '../../domain/train_def.dart';
import '../kit/game_icon.dart';
import '../theme/app_colors.dart';

part 'run_meter_painter.dart';

/// One train in the meter: its colour, filled once it is home.
final class TrainMark {
  const TrainMark({required this.style, required this.delivered});

  final TrainStyle style;
  final bool delivered;
}

/// One minute in the meter row; [used] once played.
sealed class MeterSlot {
  const MeterSlot({required this.used});

  final bool used;
}

/// An ordinary minute.
final class MeterDot extends MeterSlot {
  const MeterDot({required super.used});
}

/// The par (or par+2) minute: finish on it or before to keep a star.
final class MeterStar extends MeterSlot {
  const MeterStar({required super.used});
}

/// The run at a glance, without words: a token per train (filled when
/// delivered) and a mark per minute (filled when used); the par and par+2
/// minutes are drawn as stars. Long runs become a bar. Screen readers get
/// [semanticsLabel].
final class RunMeter extends StatelessWidget {
  const RunMeter({
    super.key,
    required this.trains,
    required this.used,
    required this.max,
    required this.par,
    required this.semanticsLabel,
  });

  final List<TrainMark> trains;
  final int used;
  final int max;

  /// Null for tutorial levels, which award no stars.
  final int? par;
  final String semanticsLabel;

  /// More minutes than this are drawn as a bar.
  static const int dotLimit = 16;

  /// Two stars are kept up to par+2 (StarRating).
  static const int silverSlack = 2;

  static bool usesBar({required int max}) => max > dotLimit;

  static List<MeterSlot> slotsFor({
    required int used,
    required int max,
    required int? par,
  }) => [
    for (var i = 0; i < max; i++)
      if (par != null && (i + 1 == par || i + 1 == par + silverSlack))
        MeterStar(used: i < used)
      else
        MeterDot(used: i < used),
  ];

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    excludeSemantics: true,
    child: SizedBox(
      height: 22,
      width: double.infinity,
      child: CustomPaint(
        painter: _RunMeterPainter(
          trains: trains,
          slots: usesBar(max: max)
              ? null
              : slotsFor(used: used, max: max, par: par),
          used: used,
          max: max,
          par: par,
        ),
      ),
    ),
  );
}
