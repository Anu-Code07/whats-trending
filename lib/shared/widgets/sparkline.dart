import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.seed,
    this.width = 72,
    this.height = 28,
    this.color = NsPalette.accent,
  });

  final int seed;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(seed: seed, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.seed, required this.color});

  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    const points = 8;
    final values = List<double>.generate(points, (i) {
      final base = 0.25 + (i / points) * 0.45;
      return (base + (random.nextDouble() - 0.35) * 0.4).clamp(0.08, 0.95);
    });

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height * (1 - values[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.color != color;
}
