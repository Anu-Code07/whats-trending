import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/ns_palette.dart';

class NsPrimaryButton extends StatefulWidget {
  const NsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.icon = Icons.arrow_forward_rounded,
    this.showIcon = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final IconData icon;
  final bool showIcon;

  @override
  State<NsPrimaryButton> createState() => _NsPrimaryButtonState();
}

class _NsPrimaryButtonState extends State<NsPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.enabled ? 1 : 0.45,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [NsPalette.accentBright, NsPalette.accent, NsPalette.accentDeep],
              ),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: NsPalette.accent.withValues(alpha: 0.38),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (widget.showIcon) ...[
                  const SizedBox(width: 8),
                  Icon(widget.icon, color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
