import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.count = 3});

  final int count;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.count,
      itemBuilder: (_, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(-1 + _controller.value * 2, 0),
                  end: Alignment(1 + _controller.value * 2, 0),
                  colors: [
                    AppColors.cardColorForIndex(index),
                    AppColors.cardColorForIndex(index).withValues(alpha: 0.6),
                    AppColors.cardColorForIndex(index),
                  ],
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: Container(
            height: 280,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        );
      },
    );
  }
}
