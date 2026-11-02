import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum EduMeetBadgeVariant {
  live,
  upcoming,
  completed,
  oneOnOne,
  primary,
  neutral,
  error,
}

class EduMeetBadge extends StatelessWidget {
  final String label;
  final EduMeetBadgeVariant variant;
  final IconData? icon;
  final Color? customBgColor;
  final Color? customTextColor;

  const EduMeetBadge({
    super.key,
    required this.label,
    this.variant = EduMeetBadgeVariant.primary,
    this.icon,
    this.customBgColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    bool showPulse = false;

    if (customBgColor != null && customTextColor != null) {
      bg = customBgColor!;
      fg = customTextColor!;
    } else {
      switch (variant) {
        case EduMeetBadgeVariant.live:
          bg = AppColors.tertiaryFixed;
          fg = AppColors.onTertiaryFixed;
          showPulse = true;
          break;
        case EduMeetBadgeVariant.upcoming:
          bg = AppColors.secondaryFixed;
          fg = AppColors.onSecondaryFixed;
          break;
        case EduMeetBadgeVariant.completed:
          bg = AppColors.surfaceContainer;
          fg = AppColors.onSurfaceVariant;
          break;
        case EduMeetBadgeVariant.oneOnOne:
          bg = AppColors.primaryFixed;
          fg = AppColors.onPrimaryFixed;
          break;
        case EduMeetBadgeVariant.primary:
          bg = AppColors.primaryFixed.withValues(alpha: 0.5);
          fg = AppColors.primary;
          break;
        case EduMeetBadgeVariant.neutral:
          bg = AppColors.surfaceContainer;
          fg = AppColors.onSurfaceVariant;
          break;
        case EduMeetBadgeVariant.error:
          bg = AppColors.errorContainer;
          fg = AppColors.onErrorContainer;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSm(color: fg).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
