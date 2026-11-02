import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class AvatarGroup extends StatelessWidget {
  final List<String> imageUrls;
  final int totalCount;
  final double size;
  final Color borderColor;

  const AvatarGroup({
    super.key,
    required this.imageUrls,
    required this.totalCount,
    this.size = 32,
    this.borderColor = AppColors.surfaceContainerLowest,
  });

  @override
  Widget build(BuildContext context) {
    final displayUrls = imageUrls.take(3).toList();
    final remaining = totalCount > displayUrls.length ? totalCount - displayUrls.length : 0;

    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < displayUrls.length; i++)
            Align(
              widthFactor: 0.72,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: displayUrls[i],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primaryFixed,
                      child: const Center(
                        child: Icon(Icons.person, size: 16, color: AppColors.primary),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryFixed,
                      child: const Center(
                        child: Icon(Icons.person, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (remaining > 0)
            Align(
              widthFactor: 0.75,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: AppTypography.labelSm(color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: size * 0.35,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

