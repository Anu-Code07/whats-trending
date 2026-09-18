import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';

class GlassStackHero extends StatelessWidget {
  const GlassStackHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-36, 18),
            child: Transform.rotate(
              angle: -0.22,
              child: const _GlassCard(),
            ),
          ),
          Transform.translate(
            offset: const Offset(40, 10),
            child: Transform.rotate(
              angle: 0.2,
              child: const _GlassCard(),
            ),
          ),
          const _GlassCard(featured: true),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({this.featured = false});

  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: featured
              ? [
                  const Color(0xFF7C6CFF).withValues(alpha: 0.45),
                  const Color(0xFF312E81).withValues(alpha: 0.35),
                ]
              : [
                  Colors.white.withValues(alpha: 0.08),
                  const Color(0xFF6366F1).withValues(alpha: 0.12),
                ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: featured ? 0.22 : 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: NsPalette.accent.withValues(alpha: featured ? 0.28 : 0.08),
            blurRadius: featured ? 30 : 12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: featured
          ? const Center(
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            )
          : null,
    );
  }
}
