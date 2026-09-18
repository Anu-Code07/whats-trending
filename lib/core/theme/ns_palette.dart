import 'package:flutter/material.dart';

/// Dual light/dark tokens matching the Northstar editorial mockup.
class NsPalette {
  const NsPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.navBackground,
    required this.cardShadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color navBackground;
  final Color cardShadow;

  static const accent = Color(0xFF8B7CFF);
  static const accentBright = Color(0xFFA78BFA);
  static const accentDeep = Color(0xFF6D5CE7);
  static const accentMuted = Color(0x338B7CFF);
  static const accentGlow = Color(0x408B7CFF);

  static const signal = Color(0xFF34D399);
  static const signalMuted = Color(0x1A34D399);
  static const warning = Color(0xFFFBBF24);
  static const impactHigh = Color(0xFFF97316);
  static const impactCritical = Color(0xFFEF4444);

  static const dark = NsPalette(
    background: Color(0xFF08080F),
    surface: Color(0xFF12121B),
    surfaceElevated: Color(0xFF1A1A26),
    border: Color(0xFF2A2A38),
    textPrimary: Color(0xFFF5F5F8),
    textSecondary: Color(0xFF9898A6),
    textTertiary: Color(0xFF636372),
    navBackground: Color(0xFF0E0E16),
    cardShadow: Color(0x00000000),
  );

  static const light = NsPalette(
    background: Color(0xFFF6F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F0F5),
    border: Color(0xFFE6E6EE),
    textPrimary: Color(0xFF0C0C14),
    textSecondary: Color(0xFF6B6B7A),
    textTertiary: Color(0xFF9A9AA8),
    navBackground: Color(0xFFFFFFFF),
    cardShadow: Color(0x140C0C14),
  );

  static NsPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

extension NsContext on BuildContext {
  NsPalette get ns => NsPalette.of(this);
}
