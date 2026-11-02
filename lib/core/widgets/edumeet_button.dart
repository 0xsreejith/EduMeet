import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum EduMeetButtonVariant {
  primary,
  secondary,
  tertiary,
  outlined,
  error,
}

class EduMeetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EduMeetButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const EduMeetButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = EduMeetButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case EduMeetButtonVariant.primary:
        bg = AppColors.primary;
        fg = AppColors.onPrimary;
        break;
      case EduMeetButtonVariant.secondary:
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        break;
      case EduMeetButtonVariant.tertiary:
        bg = AppColors.tertiary;
        fg = AppColors.onTertiary;
        break;
      case EduMeetButtonVariant.outlined:
        bg = Colors.transparent;
        fg = AppColors.primary;
        border = const BorderSide(color: AppColors.outlineVariant);
        break;
      case EduMeetButtonVariant.error:
        bg = AppColors.error;
        fg = AppColors.onError;
        break;
    }

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLg(color: fg).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        elevation: (variant == EduMeetButtonVariant.primary && onPressed != null) ? 1 : 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
