import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/portal/visit_text.dart';
import 'doctor_tile.dart';

/// The doctors who take online bookings, with the price of the chosen kind of visit; a note when there are none.
class DoctorList extends StatelessWidget {
  const DoctorList({
    super.key,
    required this.doctors,
    required this.type,
    required this.selectedId,
    required this.onPick,
  });

  final List<Doctor> doctors;

  /// The kind of visit: its price is shown on each doctor.
  final AppointmentType type;
  final String? selectedId;
  final ValueChanged<Doctor> onPick;

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const EmptyState(
        icon: Icons.person_search_rounded,
        title: VisitText.noDoctors,
        message: VisitText.noDoctorsHint,
      );
    }
    return Column(
      children: [
        for (final doctor in doctors)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: DoctorTile(
              doctor: doctor,
              price: _price(doctor),
              selected: selectedId == doctor.id,
              onTap: () => onPick(doctor),
            ),
          ),
      ],
    );
  }

  Money? _price(Doctor doctor) =>
      (type == AppointmentType.followUp ? doctor.followUpService : doctor.consultationService)?.price;
}
