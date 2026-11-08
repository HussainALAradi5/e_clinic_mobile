import 'package:e_clinic_core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shared/enum_catalog.dart';
import 'accounting/month_summary_repository.dart';
import 'audit/activity_repository.dart';
import 'billing/appointment_fee_repository.dart';
import 'billing/invoice_repository.dart';
import 'billing/package_repository.dart';
import 'billing/refund_repository.dart';
import 'billing/wallet_repository.dart';
import 'clinic/appointment_repository.dart';
import 'clinic/clinical_order_repository.dart';
import 'clinic/doctor_repository.dart';
import 'clinic/patient_repository.dart';
import 'clinic/portal_repository.dart';
import 'clinic/sick_leave_repository.dart';
import 'clinic/treatment_repository.dart';
import 'communication/chat_repository.dart';
import 'communication/ticket_repository.dart';
import 'documents/document_repository.dart';
import 'finance/expense_repository.dart';
import 'hr/attendance_repository.dart';
import 'hr/earning_repository.dart';
import 'hr/leave_repository.dart';
import 'hr/staff_request_repository.dart';
import 'identity/attachment_repository.dart';
import 'identity/auth_repository.dart';
import 'identity/code_repository.dart';
import 'identity/meta_repository.dart';
import 'identity/notification_repository.dart';
import 'identity/signature_repository.dart';
import 'pharmacy/dispensation_repository.dart';
import 'pharmacy/prescription_repository.dart';
import 'reference/clinic_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(apiClientProvider)));
final portalRepositoryProvider = Provider((ref) => PortalRepository(ref.watch(apiClientProvider)));
final appointmentRepositoryProvider = Provider((ref) => AppointmentRepository(ref.watch(apiClientProvider)));
final doctorRepositoryProvider = Provider((ref) => DoctorRepository(ref.watch(apiClientProvider)));
final treatmentRepositoryProvider = Provider((ref) => TreatmentRepository(ref.watch(apiClientProvider)));
final clinicalOrderRepositoryProvider = Provider((ref) => ClinicalOrderRepository(ref.watch(apiClientProvider)));
final signatureRepositoryProvider = Provider((ref) => SignatureRepository(ref.watch(apiClientProvider)));
final documentRepositoryProvider = Provider((ref) => DocumentRepository(ref.watch(apiClientProvider)));
final attachmentRepositoryProvider = Provider((ref) => AttachmentRepository(ref.watch(apiClientProvider)));
final prescriptionRepositoryProvider = Provider((ref) => PrescriptionRepository(ref.watch(apiClientProvider)));
final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository(ref.watch(apiClientProvider)));
final appointmentFeeRepositoryProvider = Provider((ref) => AppointmentFeeRepository(ref.watch(apiClientProvider)));
final packageRepositoryProvider = Provider((ref) => PackageRepository(ref.watch(apiClientProvider)));
final earningRepositoryProvider = Provider((ref) => EarningRepository(ref.watch(apiClientProvider)));
final monthSummaryRepositoryProvider = Provider((ref) => MonthSummaryRepository(ref.watch(apiClientProvider)));
final walletRepositoryProvider = Provider((ref) => WalletRepository(ref.watch(apiClientProvider)));
final notificationRepositoryProvider = Provider((ref) => NotificationRepository(ref.watch(apiClientProvider)));
final metaRepositoryProvider = Provider((ref) => MetaRepository(ref.watch(apiClientProvider)));
final activityRepositoryProvider = Provider((ref) => ActivityRepository(ref.watch(apiClientProvider)));
final codeRepositoryProvider = Provider((ref) => CodeRepository(ref.watch(apiClientProvider)));
final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository(ref.watch(apiClientProvider)));
final refundRepositoryProvider = Provider((ref) => RefundRepository(ref.watch(apiClientProvider)));
final expenseRepositoryProvider = Provider((ref) => ExpenseRepository(ref.watch(apiClientProvider)));
final patientRepositoryProvider = Provider((ref) => PatientRepository(ref.watch(apiClientProvider)));
final dispensationRepositoryProvider = Provider((ref) => DispensationRepository(ref.watch(apiClientProvider)));
final leaveRepositoryProvider = Provider((ref) => LeaveRepository(ref.watch(apiClientProvider)));
final staffRequestRepositoryProvider = Provider((ref) => StaffRequestRepository(ref.watch(apiClientProvider)));
final sickLeaveRepositoryProvider = Provider((ref) => SickLeaveRepository(ref.watch(apiClientProvider)));
final chatRepositoryProvider = Provider((ref) => ChatRepository(ref.watch(apiClientProvider)));
final ticketRepositoryProvider = Provider((ref) => TicketRepository(ref.watch(apiClientProvider)));

final clinicRepositoryProvider = Provider((ref) => ClinicRepository(ref.watch(apiClientProvider)));

/// Enum labels; falls back to humanised values while loading or offline.
final enumCatalogProvider = FutureProvider<EnumCatalog>(
  (ref) => ref.watch(metaRepositoryProvider).enums().catchError((Object _) => EnumCatalog.empty),
);
