import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/booking_providers.dart';
import '../application/portal_providers.dart';
import '../portal_paths.dart';

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
    final theme = Theme.of(context);
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
                    child: _DoctorTile(
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
                _Slots(slotKey: _slotKey!, selected: _slot, onPick: (slot) => setState(() => _slot = slot)),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_doctor != null && _slot != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${ClinicClock.day(_date)} at ${_slot!.startTime} with ${_doctor!.displayName}',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              AppButton(
                label: _slot == null ? 'Pick a doctor and a time' : 'Book visit',
                icon: Icons.event_available_rounded,
                lock: ButtonLock.once,
                expand: true,
                onPressed: _doctor != null && _slot != null ? _book : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile({required this.doctor, required this.price, required this.selected, required this.onTap});

  final Doctor doctor;
  final Money? price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected ? scheme.primary : scheme.secondaryContainer,
                foregroundColor: selected ? scheme.onPrimary : scheme.onSecondaryContainer,
                child: Text(initials(doctor.fullName)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.displayName, style: theme.textTheme.titleSmall),
                    if (doctor.specialty != null)
                      Text(
                        doctor.specialty!.name,
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              if (price != null) Text(price!.label, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slots extends ConsumerWidget {
  const _Slots({required this.slotKey, required this.selected, required this.onPick});

  final SlotKey slotKey;
  final Slot? selected;
  final ValueChanged<Slot> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(slotsProvider(slotKey));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: slots.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(slotsProvider(slotKey))),
        data: (list) => list.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No free times this day — try another day.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in list)
                    ChoiceChip(
                      label: Text(slot.startTime),
                      selected: selected?.startTime == slot.startTime,
                      onSelected: (_) => onPick(slot),
                    ),
                ],
              ),
      ),
    );
  }
}
