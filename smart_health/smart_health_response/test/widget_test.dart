import 'package:flutter_test/flutter_test.dart';
import 'package:smart_health_response/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHealthApp());
    expect(find.byType(SmartHealthApp), findsOneWidget);
  });
}
