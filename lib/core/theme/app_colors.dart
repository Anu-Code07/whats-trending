import 'package:flutter/material.dart';
import 'ns_palette.dart';

/// Legacy aliases — prefer [NsPalette] / [context.ns] in new UI.
abstract final class AppColors {
  static const background = Color(0xFF08080F);
  static const surface = Color(0xFF12121B);
  static const surfaceElevated = Color(0xFF1A1A26);
  static const border = Color(0xFF2A2A38);

  static const textPrimary = Color(0xFFF5F5F8);
  static const textSecondary = Color(0xFF9898A6);
  static const textTertiary = Color(0xFF636372);

  static const accent = NsPalette.accent;
  static const accentMuted = NsPalette.accentMuted;

  static const relevanceHigh = NsPalette.signal;
  static const relevanceMid = NsPalette.warning;
  static const impactCritical = NsPalette.impactCritical;
  static const impactHigh = NsPalette.impactHigh;
}
