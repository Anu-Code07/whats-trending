import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';

class OrbBackdrop extends StatelessWidget {
  const OrbBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xFF08080F))),
        Positioned(
          top: -80,
          right: -40,
          child: _Orb(color: NsPalette.accent.withValues(alpha: 0.22), size: 260),
        ),
        Positioned(
          bottom: 80,
          left: -80,
          child: _Orb(color: const Color(0xFF6366F1).withValues(alpha: 0.16), size: 280),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
