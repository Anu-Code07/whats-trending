import 'package:flutter/material.dart';
import 'signal_badge.dart';

class RelevanceBadge extends StatelessWidget {
  const RelevanceBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SignalBadge(percent: percent);
  }
}
