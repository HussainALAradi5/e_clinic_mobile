import 'package:e_clinic_app/src/portal/portal_paths.dart';
import 'package:e_clinic_app/src/router.dart';
import 'package:e_clinic_app/src/staff/staff_paths.dart';
import 'package:e_clinic_core/core.dart';
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

  test('staff pages outside the tabs follow their own rights', () {
    const pharmacist = Access({'dispensing.create', 'dispensing.dispense', 'prescriptions.read_all'}, signedIn: true);
    const desk = Access({'patients.read_all', 'appointments.read_all', 'appointments.create'}, signedIn: true);

    expect(areaRedirect(receptionist, StaffPaths.patients, pharmacist.can), StaffPaths.today);
    expect(areaRedirect(receptionist, StaffPaths.dispense, pharmacist.can), isNull);
    expect(areaRedirect(receptionist, StaffPaths.dispenseFor('rx1'), pharmacist.can), isNull);
    expect(areaRedirect(receptionist, StaffPaths.leaves, pharmacist.can), StaffPaths.today);

    expect(areaRedirect(receptionist, StaffPaths.patient('p1'), desk.can), isNull);
    expect(areaRedirect(receptionist, StaffPaths.book, desk.can), isNull);
    expect(areaRedirect(receptionist, StaffPaths.calendar, desk.can), isNull);
    expect(areaRedirect(receptionist, StaffPaths.order('o1'), desk.can), StaffPaths.today);
    expect(areaRedirect(receptionist, StaffPaths.dispensations, desk.can), StaffPaths.today);

    // Patients never reach them, whatever they hold.
    expect(areaRedirect(patient, StaffPaths.dispense, pharmacist.can), PortalPaths.home);
  });

  test('staff tabs still follow the rights; shared pages are open to both', () {
    expect(areaRedirect(receptionist, StaffPaths.approvals, frontDesk), StaffPaths.today);
    expect(areaRedirect(patient, '/account/security', frontDesk), isNull);
    expect(areaRedirect(receptionist, '/account/security', frontDesk), isNull);
  });
}
