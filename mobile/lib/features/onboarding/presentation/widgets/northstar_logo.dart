import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NorthstarLogo extends StatefulWidget {
  const NorthstarLogo({super.key, this.size = 80});

  final double size;

  @override
  State<NorthstarLogo> createState() => _NorthstarLogoState();
}

class _NorthstarLogoState extends State<NorthstarLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Container(
          width: widget.size + 40,
          height: widget.size + 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.15 + _controller.value * 0.1),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.size + 40, widget.size + 40),
        painter: _StarPainter(animation: _controller.value),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.animation});
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius + 8, glowPaint);

    // 4-point north star
    final starPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final glowStarPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    const points = 4;
    final innerRadius = radius * 0.35;
    final outerRadius = radius * 0.9;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2 + animation * 0.1;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, glowStarPaint);
    canvas.drawPath(path, starPaint);

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.animation != animation;
}
