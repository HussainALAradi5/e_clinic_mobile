import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../controllers/portal/booking_providers.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/booking/doctor_tile.dart';
import '../../widgets/portal/booking/slot_choices.dart';

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
  static const _types = [(AppointmentType.consultation, 'New problem'), (AppointmentType.followUp, 'Follow-up')];

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

  Money? _price(Doctor doctor) =>
      (_type == AppointmentType.followUp ? doctor.followUpService : doctor.consultationService)?.price;

  Future<void> _book() async {
    final doctor = _doctor;
    final slot = _slot;
    if (doctor == null || slot == null) throw const ActionCancelled();
    try {
      await ref
          .read(portalRepositoryProvider)
          .book(
            doctorId: doctor.id,
            type: _type,
            date: _date,
            startTime: slot.startTime,
            reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
            idempotencyKey: _idempotencyKey,
          );
    } on ApiException catch (error) {
      // Someone else may have taken the time: show fresh times and let the patient pick again.
      if (!error.isOffline && mounted) {
        _idempotencyKey = ApiClient.newIdempotencyKey();
        ref.invalidate(slotsProvider(_slotKey!));
        setState(() => _slot = null);
      }
      rethrow;
    }
    ref.read(visitsVersionProvider.notifier).bump();
    if (!mounted) return;
    AppSnack.success(context, 'Booking sent. The clinic will confirm it shortly.');
    context.go(PortalPaths.visits);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<AppointmentType>(
                  showSelectedIcon: false,
                  segments: [for (final (value, label) in _types) ButtonSegment(value: value, label: Text(label))],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() {
                    _type = s.first;
                    _slot = null;
                  }),
                ),
              ),
              if (data.specialties.length > 1) ...[
                const SectionHeader('Specialty'),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final s in [null, ...data.specialties])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(s?.name ?? 'All'),
                            selected: _specialtyId == s?.id,
                            onSelected: (_) => setState(() {
                              _specialtyId = s?.id;
                              if (_doctor != null && s != null && _doctor!.specialtyId != s.id) {
                                _doctor = null;
                                _slot = null;
                              }
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SectionHeader('Doctor'),
              if (doctors.isEmpty)
                const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No doctor takes online bookings here yet',
                  message: 'Call the clinic and the front desk will book you in.',
                )
              else
                for (final doctor in doctors)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: DoctorTile(
                      doctor: doctor,
                      price: _price(doctor),
                      selected: _doctor?.id == doctor.id,
                      onTap: () => setState(() {
                        _doctor = doctor;
                        _slot = null;
                      }),
                    ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _reason,
                    maxLength: 500,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: 'e.g. knee pain for two weeks'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: BottomBar(
        summary: _doctor != null && _slot != null
            ? '${ClinicClock.day(_date)} at ${_slot!.startTime} with ${_doctor!.displayName}'
            : null,
        child: AppButton(
          label: _slot == null ? 'Pick a doctor and a time' : 'Book visit',
          icon: Icons.event_available_rounded,
          lock: ButtonLock.once,
          expand: true,
          onPressed: _doctor != null && _slot != null ? _book : null,
        ),
      ),
    );
  }
}
