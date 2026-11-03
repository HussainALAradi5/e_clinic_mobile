import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/staff/staff_providers.dart';
import '../../widgets/staff/clock/clock_card.dart';
import '../../widgets/staff/today/no_schedule_notice.dart';
import '../../widgets/staff/today/schedule_visits.dart';

/// `/` — the staff member's day: clock in / out, then today's bookings by stage (expected → waiting → with the
/// doctor → done) with the next step on each card. Front-desk staff can switch between their own and everyone's.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  /// Like the web front-desk board: arrivals and steps taken by colleagues show up without pulling down.
  static const _autoRefresh = Duration(seconds: 30);

  var _stage = VisitStage.all;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh only while this tab is on screen (tabs off screen have their tickers muted by the shell).
    final onScreen = TickerMode.valuesOf(context).enabled;
    _timer?.cancel();
    _timer = onScreen
        ? Timer.periodic(_autoRefresh, (_) {
            if (ref.read(canSeeScheduleProvider)) ref.invalidate(todayScheduleProvider);
          })
        : null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(todayScheduleProvider)
      ..invalidate(todayClockProvider)
      ..invalidate(approvalsCountProvider);
    if (ref.read(canSeeScheduleProvider)) await ref.read(todayScheduleProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final access = ref.watch(accessProvider);
    final canSchedule = ref.watch(canSeeScheduleProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              GreetingHeader(firstName: user?.firstName ?? ''),
              if (access.can('attendance.self'))
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: ClockCard()),
              if (canSchedule) ..._schedule(context, access) else const NoScheduleNotice(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _schedule(BuildContext context, Access access) {
    final schedule = ref.watch(todayScheduleProvider);
    final mine = ref.watch(onlyMineProvider);
    // People who only read their own bookings have nothing to switch to.
    final canSwitch = access.can('appointments.read_all');
    final all = schedule.value?.visits ?? const <Appointment>[];
    int count(VisitStage stage) => all.where(stage.includes).length;

    return [
      SectionHeader(
        mine ? 'My schedule' : 'Clinic schedule',
        trailing: canSwitch
            ? SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Mine')),
                  ButtonSegment(value: false, label: Text('All')),
                ],
                selected: {mine},
                onSelectionChanged: (value) => ref.read(onlyMineProvider.notifier).set(value.first),
              )
            : null,
      ),
      ChipBar<VisitStage>(
        options: [
          for (final stage in VisitStage.values)
            // "All" always shows the day's total; the stages only when something is in them.
            (
              value: stage,
              label: stage.label,
              count: !schedule.hasValue || (stage != VisitStage.all && count(stage) == 0) ? null : count(stage),
            ),
        ],
        selected: _stage,
        onSelected: (stage) => setState(() => _stage = stage),
      ),
      const SizedBox(height: 12),
      schedule.when(
        loading: () => const SkeletonList(count: 3, height: 140),
        error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(todayScheduleProvider)),
        data: (day) =>
            ScheduleVisits(day: day, stage: _stage, mine: mine, onRetry: () => ref.invalidate(todayScheduleProvider)),
      ),
    ];
  }
}
