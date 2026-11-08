import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a label with a tone shows its value as a badge, others stay plain text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FactList(
            tones: {'File number': StatusTone.cyan},
            facts: [
              (label: 'File number', value: 'PRS-000027'),
              (label: 'Mobile', value: '+97300000000'),
              (label: 'Empty', value: null),
            ],
          ),
        ),
      ),
    );

    expect(find.widgetWithText(StatusBadge, 'PRS-000027'), findsOneWidget);
    expect(find.widgetWithText(StatusBadge, '+97300000000'), findsNothing);
    expect(find.text('+97300000000'), findsOneWidget);
    expect(find.text('Empty'), findsNothing);
  });
}
