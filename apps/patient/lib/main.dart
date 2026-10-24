import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_features/features.dart';

import 'src/app.dart';

Future<void> main() =>
    runClinicApp(app: MobileApp.patient, lockAfter: const Duration(minutes: 5), root: const PatientApp());
