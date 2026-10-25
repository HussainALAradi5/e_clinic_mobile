import 'package:e_clinic_app/src/portal/portal_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messages lead to the page of their record', () {
    expect(PortalPaths.forRelated('appointment'), PortalPaths.visits);
    expect(PortalPaths.forRelated('payment'), PortalPaths.invoices);
    expect(PortalPaths.forRelated('clinical_order'), PortalPaths.results);
    expect(PortalPaths.forRelated('something_else'), isNull);
  });
}
