import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/motion.dart';
import 'game_icon.dart';
import 'motion_settings.dart';

/// A station announcement strip that slides down from above; used for
/// rejected pulses and other short notices.
final class PlatformAnnouncement extends StatelessWidget {
  const PlatformAnnouncement({
    super.key,
    required this.message,
    this.serial = 0,
  });

  final String message;

  /// Change it to replay the slide (and shake) for a repeated message.
  final int serial;

  @override
  Widget build(BuildContext context) {
    final strip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GameIcon(GameIconKind.horn, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
    if (MotionSettings.reducedOf(context)) return strip;
    return strip
        .animate(key: ValueKey(serial))
        .slideY(begin: -0.6, duration: kArrival, curve: Curves.easeOutBack)
        .fadeIn(duration: kArrival)
        .shakeX(delay: kArrival, duration: kCollisionFlash, hz: 5, amount: 3);
  }
}
