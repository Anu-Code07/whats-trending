import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark app shell
  static const background = Color(0xFF0D0D0F);
  static const surface = Color(0xFF161618);
  static const surfaceElevated = Color(0xFF1E1E22);
  static const border = Color(0xFF2C2C30);

  static const textPrimary = Color(0xFFF2F2F4);
  static const textSecondary = Color(0xFF9B9BA4);
  static const textTertiary = Color(0xFF63636C);

  static const accent = Color(0xFF1A1A1A);
  static const accentLight = Color(0xFFF5F0E6);
  static const accentMuted = Color(0x1AF5F0E6);
  static const highlight = Color(0xFFF5F0E6);

  static const live = Color(0xFFE53935);
  static const relevanceHigh = Color(0xFF2E7D32);
  static const relevanceMid = Color(0xFFE6A817);
  static const impactCritical = Color(0xFFE53935);
  static const impactHigh = Color(0xFFE07B4B);

  // Light card palette (pastels on dark shell)
  static const cardCream = Color(0xFFF5F0E6);
  static const cardPink = Color(0xFFF8E4E4);
  static const cardBlue = Color(0xFFE4EDF8);
  static const cardMint = Color(0xFFE8F5EF);

  static const cardText = Color(0xFF1A1A1A);
  static const cardTextSecondary = Color(0xFF6B6B6B);
  static const cardTextMuted = Color(0xFF9A9A9A);

  static const navBar = Color(0xCC1A1A1E);
  static const navActive = Color(0xFFFFFFFF);
  static const navInactive = Color(0xFF7A7A82);

  static Color cardColorForIndex(int index) {
    return switch (index % 4) {
      0 => cardCream,
      1 => cardPink,
      2 => cardBlue,
      _ => cardMint,
    };
  }
}
