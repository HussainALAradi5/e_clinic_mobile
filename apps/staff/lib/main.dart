import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_features/features.dart';

import 'src/app.dart';

/// Staff phones hold many patients' data: they lock sooner than the patient app.
Future<void> main() =>
    runClinicApp(app: MobileApp.staff, lockAfter: const Duration(minutes: 2), root: const StaffApp());
