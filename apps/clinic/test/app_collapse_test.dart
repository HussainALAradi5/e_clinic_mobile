import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _collapse({bool noMotion = false, Brightness brightness = Brightness.light}) => MaterialApp(
  theme: ThemeData(brightness: brightness),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: noMotion),
    child: const Scaffold(
      body: AppCollapse(title: Text('More'), child: Text('Inside')),
    ),
  ),
);

RotationTransition _chevron(WidgetTester tester) => tester.widget<RotationTransition>(
  find.descendant(of: find.byType(AppCollapse), matching: find.byType(RotationTransition)),
);

void main() {
  testWidgets('opens and closes smoothly and drops its content while closed', (tester) async {
    await tester.pumpWidget(_collapse());
    expect(find.text('Inside'), findsNothing);

    await tester.tap(find.text('More'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.hasRunningAnimations, isTrue);
    final midHeight = tester.getSize(find.byType(SizeTransition)).height;
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsOneWidget);
    expect(tester.getSize(find.byType(SizeTransition)).height, greaterThan(midHeight));
    expect(_chevron(tester).turns.value, 0.5);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsNothing);
  });

  testWidgets('tells screen readers whether it is open', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_collapse());
    expect(
      tester.getSemantics(find.text('More')),
      isSemantics(label: 'More', isButton: true, hasExpandedState: true, isExpanded: false, hasTapAction: true),
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('More')),
      isSemantics(label: 'More', isButton: true, hasExpandedState: true, isExpanded: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('moves at once when the system asks for no animations', (tester) async {
    await tester.pumpWidget(_collapse(noMotion: true));
    await tester.tap(find.text('More'));
    await tester.pump();
    expect(tester.widget<SizeTransition>(find.byType(SizeTransition)).sizeFactor.value, 1);
    expect(_chevron(tester).turns.value, 0.5);
    expect(find.text('Inside'), findsOneWidget);
  });

  testWidgets('draws in the dark theme and starts open when asked', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(
          body: AppCollapse(title: Text('More'), initiallyOpen: true, child: Text('Inside')),
        ),
      ),
    );
    expect(find.text('Inside'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
