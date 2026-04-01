import 'package:flutter_test/flutter_test.dart';

import 'package:todaybread/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TodayBreadApp());

    expect(find.text('오늘의 빵'), findsOneWidget);
  });
}
