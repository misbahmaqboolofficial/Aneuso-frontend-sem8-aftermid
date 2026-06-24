import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aneuso_app/presentation/screens/admin/offer_form_screen.dart';

void main() {
  testWidgets('OfferFormScreen builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfferFormScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(OfferFormScreen), findsOneWidget);
  });
}
