import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/motion.dart';
import 'game_icon.dart';
import 'motion_settings.dart';

/// How an announcement sounds: an [alarm] (a rejected pulse: red, horn,
/// shake) or calm [info] (a level's rules).
enum AnnouncementTone { alarm, info }

/// A station announcement strip that slides down from above; used for
/// rejected pulses and other short notices.
final class PlatformAnnouncement extends StatelessWidget {
  const PlatformAnnouncement({
    super.key,
    required this.message,
    this.serial = 0,
    this.tone = AnnouncementTone.alarm,
  });

  final String message;
  final AnnouncementTone tone;

  /// Change it to replay the slide (and shake) for a repeated message.
  final int serial;

  @override
  Widget build(BuildContext context) {
    final alarm = tone == AnnouncementTone.alarm;
    final accent = alarm ? AppColors.danger : AppColors.accentTurquoise;
    final strip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameIcon(
            alarm ? GameIconKind.horn : GameIconKind.route,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              maxLines: 3,
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
    final arrival = strip
        .animate(key: ValueKey(serial))
        .slideY(begin: -0.6, duration: kArrival, curve: Curves.easeOutBack)
        .fadeIn(duration: kArrival);
    if (!alarm) return arrival;
    return arrival.shakeX(
      delay: kArrival,
      duration: kCollisionFlash,
      hz: 5,
      amount: 3,
    );
  }
}
