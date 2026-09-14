import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum CategoryTabStyle { pill, underline }

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    this.style = CategoryTabStyle.underline,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final CategoryTabStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: style == CategoryTabStyle.underline ? 44 : 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: style == CategoryTabStyle.underline ? 24 : 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;

          if (style == CategoryTabStyle.underline) {
            return GestureDetector(
              onTap: () => onSelected(category),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.textPrimary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppColors.background : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
