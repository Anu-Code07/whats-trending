import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/main.dart';

void main() {
  testWidgets('Pulse app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pump();
    expect(find.byType(PulseApp), findsOneWidget);
  });
}
