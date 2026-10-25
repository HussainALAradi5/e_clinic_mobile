import 'package:e_clinic_app/src/portal/portal_paths.dart';
import 'package:e_clinic_app/src/router.dart';
import 'package:e_clinic_app/src/staff/staff_paths.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_test/flutter_test.dart';

User _account(String type) =>
    User(id: 'u1', code: 'PRS-1', firstName: 'Test', lastName: 'User', fullName: 'Test User', userType: type);

void main() {
  final patient = _account('patient');
  final receptionist = _account('staff');
  bool frontDesk(String expression) => expression == 'authenticated' || expression.contains('codes.scan');

  test('each account starts on its own home', () {
    expect(homeFor(patient), PortalPaths.home);
    expect(homeFor(receptionist), StaffPaths.today);
    expect(areaRedirect(patient, '/', frontDesk), PortalPaths.home);
    expect(areaRedirect(receptionist, '/', frontDesk), StaffPaths.today);
  });

  test('patients stay in the patient screens and staff in the staff screens', () {
    expect(areaRedirect(patient, PortalPaths.results, frontDesk), isNull);
    expect(areaRedirect(patient, StaffPaths.scan, frontDesk), PortalPaths.home);
    expect(areaRedirect(patient, StaffPaths.appointment('a1'), frontDesk), PortalPaths.home);
    expect(areaRedirect(receptionist, StaffPaths.scan, frontDesk), isNull);
    expect(areaRedirect(receptionist, PortalPaths.invoices, frontDesk), StaffPaths.today);
  });

  test('staff tabs still follow the rights; shared pages are open to both', () {
    expect(areaRedirect(receptionist, StaffPaths.approvals, frontDesk), StaffPaths.today);
    expect(areaRedirect(patient, '/account/security', frontDesk), isNull);
    expect(areaRedirect(receptionist, '/account/security', frontDesk), isNull);
  });
}
