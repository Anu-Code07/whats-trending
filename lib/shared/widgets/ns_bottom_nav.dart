import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/ns_palette.dart';

class NsBottomNav extends StatelessWidget {
  const NsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.equalizer_rounded, Icons.graphic_eq, 'Pulse'),
    (Icons.explore_outlined, Icons.explore_rounded, 'Discover'),
    (Icons.bookmark_outline_rounded, Icons.bookmark_rounded, 'Saved'),
  ];

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Container(
      decoration: BoxDecoration(
        color: ns.navBackground,
        border: Border(top: BorderSide(color: ns.border, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.08 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          selected ? item.$2 : item.$1,
                          size: 24,
                          color: selected ? NsPalette.accent : ns.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? NsPalette.accent : ns.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
