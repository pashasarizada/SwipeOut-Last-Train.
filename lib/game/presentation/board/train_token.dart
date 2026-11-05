import 'package:flutter/material.dart';

import '../../domain/train_def.dart';
import '../theme/app_colors.dart';

/// A small train capsule with its symbol, so colour is not the only cue.
final class TrainToken extends StatelessWidget {
  const TrainToken({super.key, required this.train, this.size = 28});

  final TrainDef train;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = colorForStyle(train.style);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: AppColors.textPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: size * 0.5,
          ),
        ],
      ),
      child: Text(
        train.symbol.glyph,
        style: TextStyle(
          color: AppColors.background,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
