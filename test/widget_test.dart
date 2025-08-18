import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_mailer_new/main.dart'; // adjust if your package name/file differs

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app builds without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp()); // or your root widget
    // Allow any initial async work to settle
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    // No exceptions thrown during build/pump
    expect(tester.takeException(), isNull);
    // Sanity: should at least render a MaterialApp/Scaffold somewhere
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
  });
}
