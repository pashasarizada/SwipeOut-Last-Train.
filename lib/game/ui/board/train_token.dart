import 'package:flutter/material.dart';

import '../../domain/train.dart';
import '../theme/app_colors.dart';

/// A train drawn as a rounded block with its colour letter.
final class TrainToken extends StatelessWidget {
  const TrainToken({
    super.key,
    required this.train,
    required this.selected,
    required this.size,
  });

  final Train train;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = colorForTrain(train.color);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: selected ? AppColors.textPrimary : Colors.transparent,
          width: size * 0.08,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: size * 0.4,
                ),
              ]
            : const [],
      ),
      child: Text(
        train.color.symbol,
        style: TextStyle(
          color: AppColors.background,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
