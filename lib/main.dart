import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();

  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayFor(Brightness.dark));

  runApp(const NorthstarApp());
}

class NorthstarApp extends StatelessWidget {
  const NorthstarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Northstar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.create(),
      builder: (context, child) {
        return _PhoneShell(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _PhoneShell extends StatelessWidget {
  const _PhoneShell({required this.child});

  final Widget child;

  static const _maxWidth = 430.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= 520) return child;

    final framed = Size(_maxWidth, media.size.height);
    return ColoredBox(
      color: const Color(0xFF05050A),
      child: Center(
        child: MediaQuery(
          data: media.copyWith(size: framed),
          child: Container(
            width: _maxWidth,
            height: media.size.height,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 48,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        ),
      ),
    );
  }
}
