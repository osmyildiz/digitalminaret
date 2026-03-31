import 'package:digitalminaret/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app smoke test', (tester) async {
    await tester.pumpWidget(const DigitalMinaretApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
