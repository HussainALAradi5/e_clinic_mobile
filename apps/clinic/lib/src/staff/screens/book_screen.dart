import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/calendar_providers.dart';
import '../application/patient_providers.dart';
import '../application/staff_providers.dart';
import '../staff_paths.dart';
import '../widgets/booking/patient_picker_sheet.dart';
import '../widgets/patients/patient_tile.dart';

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

  /// Treatment sessions are booked from the treatment plan on the website.
  static const _types = [
    AppointmentType.consultation,
    AppointmentType.followUp,
    AppointmentType.procedure,
    AppointmentType.emergency,
    AppointmentType.teleconsultation,
  ];
  static const _sources = [
    (AppointmentSource.walkIn, 'At the desk', Icons.storefront_outlined),
    (AppointmentSource.phone, 'By phone', Icons.call_outlined),
  ];

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

  Future<void> _choosePatient() async {
    final picked = await pickPatient(context);
    if (picked != null) setState(() => _patient = picked);
  }

  Future<void> _book() async {
    if (!_ready) throw const ActionCancelled();
    final Appointment booking;
    try {
      final reason = _reason.text.trim();
      booking = await ref
          .read(appointmentRepositoryProvider)
          .book(
            patientId: _patient!.id,
            providerId: _provider!.id,
            type: _type,
            date: _date,
            startTime: _slot!.startTime,
            source: _source,
            reason: reason.isEmpty ? null : reason,
            idempotencyKey: _idempotencyKey,
          );
    } on ApiException catch (error) {
      // The time may have gone meanwhile: show fresh times and pick again.
      if (!error.isOffline && mounted) {
        _idempotencyKey = ApiClient.newIdempotencyKey();
        ref.invalidate(staffSlotsProvider(_slotKey!));
        setState(() => _slot = null);
      }
      rethrow;
    }
    ref.read(scheduleVersionProvider.notifier).bump();
    if (!mounted) return;
    AppSnack.success(context, 'Booked for ${_patient!.fullName}.');
    context.pushReplacement(StaffPaths.appointment(booking.id));
  }

  void _reset({bool provider = false}) {
    _slot = null;
    if (provider) _provider = null;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return Scaffold(
      appBar: AppBar(title: const Text('Book a visit')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader('Patient'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _patient == null
                ? OutlinedButton.icon(
                    onPressed: _choosePatient,
                    icon: const Icon(Icons.person_search_rounded),
                    label: const Text('Find the patient'),
                  )
                : PatientTile(
                    patient: _patient!,
                    onTap: _choosePatient,
                    trailing: const Icon(Icons.swap_horiz_rounded),
                  ),
          ),
          const SectionHeader('Kind of visit'),
          ChipBar<AppointmentType>(
            options: [for (final t in _types) (value: t, label: catalog.label('AppointmentType', t), count: null)],
            selected: _type,
            tone: (t) => StatusColors.tone('AppointmentType', wireValue(t)),
            onSelected: (t) => setState(() {
              _type = t;
              _reset(provider: true);
            }),
          ),
          const SectionHeader('With'),
          ref
              .watch(bookingProvidersProvider(_type))
              .when(
                loading: () => const SkeletonList(count: 2, height: 56),
                error: (error, _) =>
                    ErrorState(error: error, onRetry: () => ref.invalidate(bookingProvidersProvider(_type))),
                data: (providers) => providers.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: InfoNote(icon: Icons.person_off_outlined, text: 'Nobody takes this kind of visit.'),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final p in providers)
                              ChoiceChip(
                                avatar: CircleAvatar(child: Text(initials(p.fullName))),
                                label: Text(p.fullName),
                                tooltip: [p.jobTitle, p.department].whereType<String>().join(' · '),
                                selected: _provider?.id == p.id,
                                onSelected: (_) => setState(() {
                                  _provider = p;
                                  _reset();
                                }),
                              ),
                          ],
                        ),
                      ),
              ),
          if (_slotKey case final key?) ...[
            const SectionHeader('Day'),
            DayStrip(
              days: _days,
              selected: _date,
              onSelected: (day) => setState(() {
                _date = day;
                _reset();
              }),
            ),
            const SectionHeader('Time'),
            SlotPicker(
              slots: ref.watch(staffSlotsProvider(key)),
              selected: _slot,
              onPick: (slot) => setState(() => _slot = slot),
              onRetry: () => ref.invalidate(staffSlotsProvider(key)),
            ),
          ],
          const SectionHeader('How did they book?'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppointmentSource>(
              showSelectedIcon: false,
              segments: [
                for (final (value, label, icon) in _sources)
                  ButtonSegment(value: value, label: Text(label), icon: Icon(icon)),
              ],
              selected: {_source},
              onSelectionChanged: (s) => setState(() => _source = s.first),
            ),
          ),
          const SectionHeader('Reason (optional)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _reason,
              maxLength: 500,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. follow-up of blood test'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        summary: _ready
            ? '${_patient!.fullName} · ${ClinicClock.day(_date)} at ${_slot!.startTime} with ${_provider!.fullName}'
            : null,
        child: AppButton(
          label: _ready ? 'Book visit' : 'Choose patient, provider and time',
          icon: Icons.event_available_rounded,
          lock: ButtonLock.once,
          expand: true,
          onPressed: _ready ? _book : null,
        ),
      ),
    );
  }
}
