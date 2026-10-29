import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/portal_providers.dart';
import '../widgets/results/result_detail.dart';

/// `/results` — completed tests and scans, newest first; each opens to the report and its files.
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return Scaffold(
      appBar: AppBar(title: const Text('My results')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(resultsProvider.future),
        child: AsyncBody(
          value: ref.watch(resultsProvider),
          onRetry: () => ref.invalidate(resultsProvider),
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
                            child: Icon(order.type.isImaging ? Icons.image_search_rounded : Icons.biotech_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.description, style: theme.textTheme.titleSmall),
                                Text(
                                  [
                                    catalog.label('ClinicalOrderType', order.type),
                                    if (order.completedAt != null) ClinicClock.dateTime(order.completedAt!),
                                  ].join(' · '),
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
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
    );
  }
}
