import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';

class SignalBadge extends StatelessWidget {
  const SignalBadge({
    super.key,
    required this.percent,
    this.compact = false,
  });

  final int percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 90
        ? NsPalette.signal
        : percent >= 75
            ? NsPalette.warning
            : context.ns.textTertiary;

    return Text(
      compact ? '$percent%' : '$percent% signal',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 11 : 12,
          ),
    );
  }
}
