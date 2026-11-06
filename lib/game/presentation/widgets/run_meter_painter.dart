part of 'run_meter.dart';

/// Paints the [RunMeter]: train tokens, then minute dots or a bar.
final class _RunMeterPainter extends CustomPainter {
  _RunMeterPainter({
    required this.trains,
    required this.slots,
    required this.used,
    required this.max,
    required this.par,
  });

  final List<TrainMark> trains;

  /// Null when the minutes are drawn as a bar.
  final List<MeterSlot>? slots;
  final int used;
  final int max;
  final int? par;

  static const double _token = 18;
  static const double _gap = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    for (var i = 0; i < trains.length; i++) {
      _paintToken(canvas, Offset(i * _token + _token / 2, cy), trains[i]);
    }
    final left = trains.length * _token + _gap;
    final width = size.width - left;
    if (width <= 0) return;
    final row = Rect.fromLTWH(left, 0, width, size.height);
    if (slots case final slots?) {
      _paintSlots(canvas, row, slots);
    } else {
      _paintBar(canvas, row);
    }
  }

  void _paintToken(Canvas canvas, Offset c, TrainMark mark) {
    final color = colorForStyle(mark.style);
    final car = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 14, height: 9),
      const Radius.circular(3),
    );
    if (mark.delivered) {
      canvas.drawRRect(car, Paint()..color = color);
    } else {
      canvas.drawRRect(
        car,
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  void _paintSlots(Canvas canvas, Rect row, List<MeterSlot> slots) {
    final pitch = (row.width / slots.length).clamp(0.0, 16.0);
    final radius = (pitch * 0.3).clamp(0.0, 4.5);
    for (var i = 0; i < slots.length; i++) {
      final c = Offset(row.left + pitch * (i + 0.5), row.center.dy);
      switch (slots[i]) {
        case MeterDot(used: true):
          canvas.drawCircle(c, radius, Paint()..color = AppColors.accentAmber);
        case MeterDot(used: false):
          canvas.drawCircle(
            c,
            radius,
            Paint()
              ..color = AppColors.textSecondary
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
        case MeterStar(:final used):
          _paintStar(canvas, c, pitch * 0.48, filled: used);
      }
    }
  }

  void _paintBar(Canvas canvas, Rect row) {
    final bar = Rect.fromCenter(
      center: row.center,
      width: row.width,
      height: 8,
    );
    final radius = const Radius.circular(4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, radius),
      Paint()..color = AppColors.surface,
    );
    final filled = Rect.fromLTWH(
      bar.left,
      bar.top,
      bar.width * (used / max).clamp(0.0, 1.0),
      bar.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(filled, radius),
      Paint()..color = AppColors.accentAmber,
    );
    if (par case final par?) {
      for (final mark in [par, par + RunMeter.silverSlack]) {
        if (mark >= max) continue;
        _paintStar(
          canvas,
          Offset(bar.left + bar.width * mark / max, row.center.dy),
          6,
          filled: used >= mark,
        );
      }
    }
  }

  /// Outlined until its minute is played, then amber like a used minute.
  void _paintStar(Canvas canvas, Offset c, double r, {required bool filled}) =>
      GameIcon.paint(
        canvas,
        filled ? GameIconKind.star : GameIconKind.starOutline,
        Rect.fromCircle(center: c, radius: r),
        filled ? AppColors.accentAmber : AppColors.textSecondary,
      );

  @override
  bool shouldRepaint(_RunMeterPainter old) =>
      old.used != used ||
      old.max != max ||
      old.par != par ||
      old.trains.length != trains.length ||
      !_sameMarks(old.trains, trains);

  static bool _sameMarks(List<TrainMark> a, List<TrainMark> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].style != b[i].style || a[i].delivered != b[i].delivered) {
        return false;
      }
    }
    return true;
  }
}
