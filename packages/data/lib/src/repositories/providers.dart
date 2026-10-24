import 'package:e_clinic_core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enum_catalog.dart';
import 'auth_repository.dart';
import 'clinic_repositories.dart';
import 'other_repositories.dart';
import 'portal_repository.dart';
import 'staff_repositories.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(apiClientProvider)));
final portalRepositoryProvider = Provider((ref) => PortalRepository(ref.watch(apiClientProvider)));
final appointmentRepositoryProvider = Provider((ref) => AppointmentRepository(ref.watch(apiClientProvider)));
final doctorRepositoryProvider = Provider((ref) => DoctorRepository(ref.watch(apiClientProvider)));
final treatmentRepositoryProvider = Provider((ref) => TreatmentRepository(ref.watch(apiClientProvider)));
final clinicalOrderRepositoryProvider = Provider((ref) => ClinicalOrderRepository(ref.watch(apiClientProvider)));
final attachmentRepositoryProvider = Provider((ref) => AttachmentRepository(ref.watch(apiClientProvider)));
final prescriptionRepositoryProvider = Provider((ref) => PrescriptionRepository(ref.watch(apiClientProvider)));
final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository(ref.watch(apiClientProvider)));
final notificationRepositoryProvider = Provider((ref) => NotificationRepository(ref.watch(apiClientProvider)));
final metaRepositoryProvider = Provider((ref) => MetaRepository(ref.watch(apiClientProvider)));
final codeRepositoryProvider = Provider((ref) => CodeRepository(ref.watch(apiClientProvider)));
final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository(ref.watch(apiClientProvider)));
final refundRepositoryProvider = Provider((ref) => RefundRepository(ref.watch(apiClientProvider)));
final expenseRepositoryProvider = Provider((ref) => ExpenseRepository(ref.watch(apiClientProvider)));
final leaveRepositoryProvider = Provider((ref) => LeaveRepository(ref.watch(apiClientProvider)));

/// Enum labels; falls back to humanised values while loading or offline.
final enumCatalogProvider = FutureProvider<EnumCatalog>(
  (ref) => ref.watch(metaRepositoryProvider).enums().catchError((Object _) => EnumCatalog.empty),
);
