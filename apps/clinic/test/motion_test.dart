import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an invoice reads how much of it is paid', () {
    Invoice invoice(String total, String due) => Invoice.fromJson({
      'id': 'i-1',
      'code': 'INV-1',
      'status': 'issued',
      'total': {'amount': total},
      'paid_amount': {'amount': '0.000'},
      'balance_due': {'amount': due},
    });
    expect(invoice('15.000', '15.000').paidShare, 0);
    expect(invoice('15.000', '5.000').paidShare, closeTo(0.667, 0.001));
    expect(invoice('15.000', '0.000').paidShare, 1);
    expect(invoice('0.000', '0.000').paidShare, 1);
  });

  test('mute choices send the server values', () {
    expect(MuteDuration.values.map((d) => d.wire), ['8h', '1w', 'always']);
  });

  testWidgets('the progress bar clamps its value and fills in to it', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppProgressBar(value: 1.4, label: 'Paid', showValue: true))),
    );
    expect(find.text('100%'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value, 1);
  });

  testWidgets('motion stays still when the system asks for no animations', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: PopIn(child: Text('hi'))),
      ),
    );
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.text('hi'), findsOneWidget);
  });
}
