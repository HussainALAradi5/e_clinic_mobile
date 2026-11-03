import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../controllers/staff/booking_actions.dart';
import '../../controllers/staff/calendar_providers.dart';
import '../../controllers/staff/patient_providers.dart';
import '../../widgets/common/booking_bar.dart';
import '../../widgets/common/reason_field.dart';
import '../../widgets/staff/booking/booking_source_picker.dart';
import '../../widgets/staff/booking/patient_field.dart';
import '../../widgets/staff/booking/provider_chips.dart';
import '../../widgets/staff/booking/provider_times.dart';
import '../../widgets/staff/booking/visit_kind_chips.dart';

/// `/clinic/book` — the desk books a visit: patient → kind of visit → provider → day → free time → how they
/// asked. Desk bookings start confirmed. `?patient=<id>` (from a patient file) starts with that patient.
class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({super.key, this.patientId});

  final String? patientId;

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  static const _daysShown = 21;

  final _days = [for (var i = 0; i < _daysShown; i++) ClinicClock.addDays(ClinicClock.today(), i)];
  final _reason = TextEditingController();
  Patient? _patient;
  var _type = AppointmentType.consultation;
  BookingProvider? _provider;
  late String _date = _days.first;
  Slot? _slot;
  var _source = AppointmentSource.walkIn;
  var _idempotencyKey = ApiClient.newIdempotencyKey();

  StaffSlotKey? get _slotKey => _provider == null ? null : (providerId: _provider!.id, date: _date, type: _type);

  bool get _ready => _patient != null && _provider != null && _slot != null;

  @override
  void initState() {
    super.initState();
    final id = widget.patientId;
    if (id != null) {
      ref.read(patientProvider(id).future).then((p) {
        if (mounted && _patient == null) setState(() => _patient = p);
      }, onError: (Object _) {});
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    final (patient, key, slot) = (_patient, _slotKey, _slot);
    if (patient == null || key == null || slot == null) throw const ActionCancelled();
    final reason = _reason.text.trim();
    final booking = await StaffBookingActions.book(
      ref,
      patientId: patient.id,
      slotKey: key,
      slot: slot,
      source: _source,
      reason: reason.isEmpty ? null : reason,
      idempotencyKey: _idempotencyKey,
      onTimeGone: _pickAgain,
    );
    if (!mounted) return;
    AppSnack.success(context, 'Booked for ${patient.fullName}.');
    context.pushReplacement(StaffPaths.appointment(booking.id));
  }

  /// The time went meanwhile: a new key, and the desk picks again from fresh times.
  void _pickAgain() {
    _idempotencyKey = ApiClient.newIdempotencyKey();
    if (mounted) setState(() => _slot = null);
  }

  void _reset({bool provider = false}) {
    _slot = null;
    if (provider) _provider = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a visit')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader('Patient'),
          PatientField(patient: _patient, onChanged: (p) => setState(() => _patient = p)),
          const SectionHeader('Kind of visit'),
          VisitKindChips(
            selected: _type,
            onSelected: (t) => setState(() {
              _type = t;
              _reset(provider: true);
            }),
          ),
          const SectionHeader('With'),
          ProviderChips(
            type: _type,
            selectedId: _provider?.id,
            onSelected: (p) => setState(() {
              _provider = p;
              _reset();
            }),
          ),
          if (_slotKey case final key?)
            ProviderTimes(
              slotKey: key,
              days: _days,
              selected: _slot,
              onDay: (day) => setState(() {
                _date = day;
                _reset();
              }),
              onPick: (slot) => setState(() => _slot = slot),
            ),
          const SectionHeader('How did they book?'),
          BookingSourcePicker(selected: _source, onChanged: (s) => setState(() => _source = s)),
          const SectionHeader('Reason (optional)'),
          ReasonField(controller: _reason, hint: 'e.g. follow-up of blood test'),
        ],
      ),
      bottomNavigationBar: BookingBar(
        summary: _ready
            ? '${_patient!.fullName} · ${ClinicClock.day(_date)} at ${_slot!.startTime} with ${_provider!.fullName}'
            : null,
        label: _ready ? 'Book visit' : 'Choose patient, provider and time',
        onBook: _ready ? _book : null,
      ),
    );
  }
}
