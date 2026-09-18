import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:northstar/main.dart';
import 'package:northstar/core/di/service_locator.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ServiceLocator.init();
  });

  testWidgets('Northstar app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const NorthstarApp());
    await tester.pump();
    expect(find.byType(NorthstarApp), findsOneWidget);
    expect(find.textContaining('Tech news'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
