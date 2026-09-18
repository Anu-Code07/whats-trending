import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';

class NsSegmentedTabs extends StatelessWidget {
  const NsSegmentedTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) {
          final selected = i == index;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? ns.textPrimary : ns.textTertiary,
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(labels[i]),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.5,
                    width: selected ? 22 : 0,
                    decoration: BoxDecoration(
                      color: NsPalette.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
