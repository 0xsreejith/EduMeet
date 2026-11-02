import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class EduMeetAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const EduMeetAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.leading,
    this.showLogo = true,
    this.avatarUrl,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: preferredSize.height + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x0A000000),
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.onSurface,
                      ),
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    )
                  else if (leading != null)
                    leading!
                  else if (showLogo)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school,
                              size: 20,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'EduMeet',
                          style: AppTypography.headlineSm(color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  if (title != null && !showLogo)
                    Expanded(
                      child: Text(
                        title!,
                        style: AppTypography.headlineSm(color: AppColors.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Spacer(),
                  ...?actions,
                  if (avatarUrl != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryFixed, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(avatarUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
