import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../controllers/portal/booking_actions.dart';
import '../../controllers/portal/booking_providers.dart';
import '../../widgets/common/booking_bar.dart';
import '../../widgets/common/reason_field.dart';
import '../../widgets/portal/booking/doctor_list.dart';
import '../../widgets/portal/booking/slot_choices.dart';
import '../../widgets/portal/booking/specialty_chips.dart';
import '../../widgets/portal/booking/visit_type_picker.dart';

/// `/appointments/new` — kind of visit → specialty → doctor → day → free time → optional reason → book.
/// Times are at least two hours ahead; the booking stays pending until the clinic confirms it.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  /// Days offered in the strip (most patients look at the next three weeks).
  static const _daysShown = 21;

  final _days = [for (var i = 0; i < _daysShown; i++) ClinicClock.addDays(ClinicClock.today(), i)];
  final _reason = TextEditingController();
  var _type = AppointmentType.consultation;
  String? _specialtyId;
  Doctor? _doctor;
  late String _date = _days.first;
  Slot? _slot;
  var _idempotencyKey = ApiClient.newIdempotencyKey();

  SlotKey? get _slotKey => _doctor == null ? null : (doctorId: _doctor!.id, date: _date, type: _type);

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    final (key, slot) = (_slotKey, _slot);
    if (key == null || slot == null) throw const ActionCancelled();
    final reason = _reason.text.trim();
    await PortalBookingActions.book(
      ref,
      slotKey: key,
      slot: slot,
      reason: reason.isEmpty ? null : reason,
      idempotencyKey: _idempotencyKey,
      onTimeGone: _pickAgain,
    );
    if (!mounted) return;
    AppSnack.success(context, 'Booking sent. The clinic will confirm it shortly.');
    context.go(PortalPaths.visits);
  }

  /// Someone else took the time: a new key, and the patient picks again from fresh times.
  void _pickAgain() {
    _idempotencyKey = ApiClient.newIdempotencyKey();
    if (mounted) setState(() => _slot = null);
  }

  @override
  Widget build(BuildContext context) {
    final choices = ref.watch(bookingChoicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Book a visit')),
      body: AsyncBody(
        value: choices,
        onRetry: () => ref.invalidate(bookingChoicesProvider),
        data: (data) {
          final doctors = data.doctors.where((d) => _specialtyId == null || d.specialtyId == _specialtyId).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SectionHeader('What is the visit for?'),
              VisitTypePicker(
                selected: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  _slot = null;
                }),
              ),
              if (data.specialties.length > 1) ...[
                const SectionHeader('Specialty'),
                SpecialtyChips(
                  specialties: data.specialties,
                  selectedId: _specialtyId,
                  onSelected: (s) => setState(() {
                    _specialtyId = s?.id;
                    if (_doctor != null && s != null && _doctor!.specialtyId != s.id) {
                      _doctor = null;
                      _slot = null;
                    }
                  }),
                ),
              ],
              const SectionHeader('Doctor'),
              DoctorList(
                doctors: doctors,
                type: _type,
                selectedId: _doctor?.id,
                onPick: (doctor) => setState(() {
                  _doctor = doctor;
                  _slot = null;
                }),
              ),
              if (_doctor != null) ...[
                const SectionHeader('Day'),
                DayStrip(
                  days: _days,
                  selected: _date,
                  onSelected: (day) => setState(() {
                    _date = day;
                    _slot = null;
                  }),
                ),
                const SectionHeader('Time'),
                SlotChoices(slotKey: _slotKey!, selected: _slot, onPick: (slot) => setState(() => _slot = slot)),
                const SectionHeader('Anything the doctor should know? (optional)'),
                ReasonField(controller: _reason, hint: 'e.g. knee pain for two weeks', minLines: 2, maxLines: 4),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: BookingBar(
        summary: _doctor != null && _slot != null
            ? '${ClinicClock.day(_date)} at ${_slot!.startTime} with ${_doctor!.displayName}'
            : null,
        label: _slot == null ? 'Pick a doctor and a time' : 'Book visit',
        onBook: _doctor != null && _slot != null ? _book : null,
      ),
    );
  }
}
