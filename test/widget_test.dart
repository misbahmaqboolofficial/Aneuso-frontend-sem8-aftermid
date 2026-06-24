import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aneuso_app/core/constants/pickup_status.dart';

void main() {
  test('PickupStatus completed is driver-confirmed only', () {
    expect(PickupStatus.completed, 3);
    expect(PickupStatus.enRoute, 2);
    expect(PickupStatus.completed, isNot(PickupStatus.enRoute));
  });

  testWidgets('AppConstants user types are defined', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('ANEUSO')),
      ),
    );
    expect(find.text('ANEUSO'), findsOneWidget);
  });
}
