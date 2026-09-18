import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class NsScreen extends StatelessWidget {
  const NsScreen({
    super.key,
    required this.child,
    this.dark = false,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = dark ? AppTheme.dark : AppTheme.light;
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.overlayFor(theme.brightness),
        child: child,
      ),
    );
  }
}
