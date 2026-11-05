import 'package:flutter/painting.dart';

import '../../domain/train_def.dart';

/// Colour tokens for the midnight-metro look. Widgets never hard-code colours.
abstract final class AppColors {
  static const Color background = Color(0xFF0B1020);
  static const Color surface = Color(0xFF141B2E);
  static const Color track = Color(0xFF8A93B2);
  static const Color trackInactive = Color(0xFF3A4260);
  static const Color accentTurquoise = Color(0xFF2EC4B6);
  static const Color accentRed = Color(0xFFE5484D);
  static const Color accentAmber = Color(0xFFF5A524);
  static const Color trainBlue = Color(0xFF3B82F6);
  static const Color trainGreen = Color(0xFF22C55E);
  static const Color textPrimary = Color(0xFFE8ECF8);
  static const Color textSecondary = Color(0xFF8A93B2);
  static const Color signalGreen = Color(0xFF34D399);
  static const Color danger = Color(0xFFFF3B3B);
}

Color colorForStyle(TrainStyle style) => switch (style) {
  TrainStyle.coral => AppColors.accentRed,
  TrainStyle.azure => AppColors.trainBlue,
  TrainStyle.lime => AppColors.trainGreen,
  TrainStyle.amber => AppColors.accentAmber,
};
