import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class NewsPageHeader extends StatelessWidget {
  const NewsPageHeader({
    super.key,
    this.onMenuTap,
    this.title,
  });

  final VoidCallback? onMenuTap;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.newspaper_rounded, color: AppColors.textPrimary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title ?? AppConstants.appName,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        const Spacer(),
        if (onMenuTap != null)
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.grid_view_rounded, color: AppColors.textPrimary, size: 22),
            ),
          ),
      ],
    );
  }
}
