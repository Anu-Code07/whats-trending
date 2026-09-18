import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.count = 4});

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
    final ns = context.ns;
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
                    ns.surface,
                    ns.surfaceElevated,
                    ns.surface,
                  ],
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ns.surface,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        );
      },
    );
  }
}
