import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/month_summary_text.dart';
import '../../widgets/staff/summary/summary_tile.dart';

/// The month's summary for a given (year, month).
final _summaryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (int, int)>(
  (ref, m) => ref.watch(monthSummaryRepositoryProvider).month(m.$1, m.$2),
);

/// `/accounting/month-summary` — the owner's month at a glance next to the month before (report readers).
class MonthSummaryScreen extends ConsumerStatefulWidget {
  const MonthSummaryScreen({super.key});

  @override
  ConsumerState<MonthSummaryScreen> createState() => _MonthSummaryScreenState();
}

class _MonthSummaryScreenState extends ConsumerState<MonthSummaryScreen> {
  // Last month by default: this one is still running.
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month - 1);

  void _shift(int by) => setState(() => _month = DateTime(_month.year, _month.month + by));

  @override
  Widget build(BuildContext context) {
    final key = (_month.year, _month.month);
    final label = MaterialLocalizations.of(context).formatMonthYear(_month);
    return Scaffold(
      appBar: AppBar(title: const Text(MonthSummaryText.title)),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left_rounded)),
              SizedBox(
                width: 160,
                child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right_rounded)),
            ],
          ),
          Expanded(
            child: AsyncBody(
              value: ref.watch(_summaryProvider(key)),
              onRetry: () => ref.invalidate(_summaryProvider(key)),
              data: (s) {
                final now = s['current'] as Map<String, dynamic>;
                final before = s['previous'] as Map<String, dynamic>;
                return GridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    for (final (figure, title, lower) in MonthSummaryText.figures)
                      PopIn(
                        key: ValueKey('$figure-${_month.month}'),
                        from: 0.9,
                        child: SummaryTile(
                          label: title,
                          now: now[figure],
                          before: before[figure],
                          lowerIsBetter: lower,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
