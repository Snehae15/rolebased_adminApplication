import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rolebased_adminapplication/main.dart';

void main() {
  testWidgets('shows splash screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Analytics Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
