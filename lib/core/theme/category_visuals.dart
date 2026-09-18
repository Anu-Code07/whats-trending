import 'package:flutter/material.dart';
import 'ns_palette.dart';

class CategoryVisual {
  const CategoryVisual({
    required this.icon,
    required this.color,
    required this.gradient,
  });

  final IconData icon;
  final Color color;
  final List<Color> gradient;
}

abstract final class CategoryVisuals {
  static const _ai = CategoryVisual(
    icon: Icons.auto_awesome,
    color: Color(0xFF8B7CFF),
    gradient: [Color(0xFF7C6CFF), Color(0xFF4C1D95)],
  );
  static const _startups = CategoryVisual(
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFFF59E0B),
    gradient: [Color(0xFFF59E0B), Color(0xFFB45309)],
  );
  static const _dev = CategoryVisual(
    icon: Icons.code_rounded,
    color: Color(0xFF38BDF8),
    gradient: [Color(0xFF0EA5E9), Color(0xFF075985)],
  );
  static const _apple = CategoryVisual(
    icon: Icons.phone_iphone_rounded,
    color: Color(0xFFA1A1AA),
    gradient: [Color(0xFF3F3F46), Color(0xFF09090B)],
  );
  static const _android = CategoryVisual(
    icon: Icons.android_rounded,
    color: Color(0xFF4ADE80),
    gradient: [Color(0xFF16A34A), Color(0xFF14532D)],
  );
  static const _gaming = CategoryVisual(
    icon: Icons.sports_esports_rounded,
    color: Color(0xFFF472B6),
    gradient: [Color(0xFFEC4899), Color(0xFF9D174D)],
  );
  static const _security = CategoryVisual(
    icon: Icons.shield_rounded,
    color: Color(0xFF34D399),
    gradient: [Color(0xFF059669), Color(0xFF064E3B)],
  );
  static const _science = CategoryVisual(
    icon: Icons.science_rounded,
    color: Color(0xFF818CF8),
    gradient: [Color(0xFF6366F1), Color(0xFF312E81)],
  );
  static const _flutter = CategoryVisual(
    icon: Icons.flutter_dash,
    color: Color(0xFF38BDF8),
    gradient: [Color(0xFF22D3EE), Color(0xFF0369A1)],
  );
  static const _design = CategoryVisual(
    icon: Icons.palette_rounded,
    color: Color(0xFFC084FC),
    gradient: [Color(0xFFA855F7), Color(0xFF6B21A8)],
  );
  static const _business = CategoryVisual(
    icon: Icons.business_center_rounded,
    color: Color(0xFF94A3B8),
    gradient: [Color(0xFF64748B), Color(0xFF1E293B)],
  );
  static const _space = CategoryVisual(
    icon: Icons.rocket_outlined,
    color: Color(0xFF818CF8),
    gradient: [Color(0xFF4F46E5), Color(0xFF1E1B4B)],
  );
  static const _fallback = CategoryVisual(
    icon: Icons.bolt_rounded,
    color: NsPalette.accent,
    gradient: [Color(0xFF6D5CE7), Color(0xFF1E1B4B)],
  );

  static CategoryVisual of(String label) {
    final key = label.toLowerCase();
    if (_contains(key, ['ai', 'model', 'gpt', 'llm', 'openai', 'anthropic'])) {
      return _ai;
    }
    if (_contains(key, ['startup', 'funding', 'unicorn', 'venture'])) {
      return _startups;
    }
    if (_contains(key, ['dev', 'program', 'code', 'react', 'web', 'tool'])) {
      return _dev;
    }
    if (_contains(key, ['apple', 'ios', 'macos', 'iphone'])) return _apple;
    if (_contains(key, ['android'])) return _android;
    if (_contains(key, ['game', 'gaming', 'xbox', 'playstation'])) {
      return _gaming;
    }
    if (_contains(key, ['security', 'cyber', 'privacy', 'hack'])) {
      return _security;
    }
    if (_contains(key, ['science', 'research'])) return _science;
    if (_contains(key, ['flutter', 'dart'])) return _flutter;
    if (_contains(key, ['design', 'ui', 'ux'])) return _design;
    if (_contains(key, ['business', 'finance', 'fintech'])) return _business;
    if (_contains(key, ['space', 'nasa', 'spacex'])) return _space;
    return _fallback;
  }

  static bool _contains(String key, List<String> needles) {
    return needles.any((n) => key.contains(n));
  }

  static IconData interestIcon(String interest) => of(interest).icon;

  static Color interestColor(String interest) => of(interest).color;
}
