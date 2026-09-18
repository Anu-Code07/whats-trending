import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/category_visuals.dart';
import '../../features/home/domain/entities/story.dart';

/// Category-tinted cover art so every story feels visual without remote images.
class StoryArt extends StatelessWidget {
  const StoryArt({
    super.key,
    required this.story,
    this.height = 148,
    this.borderRadius = 18,
    this.showIcon = true,
  });

  final Story story;
  final double height;
  final double borderRadius;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisuals.of(story.category);
    final seed = story.id.hashCode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: visual.gradient,
                ),
              ),
            ),
            CustomPaint(
              painter: _MeshPainter(seed: seed, accent: visual.color),
            ),
            if (showIcon)
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(visual.icon, color: Colors.white, size: 34),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  const _MeshPainter({required this.seed, required this.accent});

  final int seed;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    for (var i = 0; i < 4; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final r = 30 + random.nextDouble() * 70;
      canvas.drawCircle(Offset(dx, dy), r, glow);
    }

    final ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      70,
      ring,
    );
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => oldDelegate.seed != seed;
}

class StoryThumb extends StatelessWidget {
  const StoryThumb({super.key, required this.story, this.size = 56});

  final Story story;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: StoryArt(story: story, height: size, borderRadius: 14, showIcon: true),
    );
  }
}
