import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/portal/portal_providers.dart';
import '../../widgets/common/date_range_chip.dart';
import '../../widgets/common/enum_filter_chips.dart';
import '../../widgets/portal/results/result_detail.dart';

/// `/results` — completed tests and scans, newest first, each with its coloured kind badge and a kind filter (on the
/// server); each opens to the report and its files.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  ClinicalOrderType? _type;
  DateTimeRange? _dates;

  ResultFilter get _filter => (
    type: _type,
    from: _dates == null ? null : ClinicClock.isoDate(_dates!.start),
    to: _dates == null ? null : ClinicClock.isoDate(_dates!.end),
  );

  static final _types = ClinicalOrderType.values.where((t) => t != ClinicalOrderType.unknown).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My results')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: EnumFilterChips(
              enumName: 'ClinicalOrderType',
              values: _types,
              selected: _type,
              onSelected: (t) => setState(() => _type = t),
            ),
          ),
          DateRangeChip(range: _dates, onChanged: (r) => setState(() => _dates = r)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(resultsProvider(_filter).future),
              child: AsyncBody(
                value: ref.watch(resultsProvider(_filter)),
                onRetry: () => ref.invalidate(resultsProvider(_filter)),
                data: (results) => results.isEmpty
                    ? ListView(
                        children: const [
                          EmptyState(
                            icon: Icons.science_outlined,
                            title: 'No results yet',
                            message: 'Test and scan results appear here once your doctor has completed them.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final order = results[i];
                          final theme = Theme.of(context);
                          return ExpandableCard(
                            header: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondaryContainer,
                                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                                  child: Icon(
                                    order.type.isImaging ? Icons.image_search_rounded : Icons.biotech_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(order.description, style: theme.textTheme.titleSmall),
                                      if (order.completedAt != null)
                                        Text(
                                          ClinicClock.dateTime(order.completedAt!),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      StatusChip(enumName: 'ClinicalOrderType', value: order.type),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            details: (_) => ResultDetail(orderId: order.id),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
