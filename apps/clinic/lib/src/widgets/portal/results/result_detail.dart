import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/portal/portal_providers.dart';
import '../../common/attachment_list.dart';

class ResultDetail extends ConsumerWidget {
  const ResultDetail({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AsyncBody(
      value: ref.watch(resultDetailProvider(orderId)),
      onRetry: () => ref.invalidate(resultDetailProvider(orderId)),
      loading: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (order) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            SelectableText(order.report ?? 'The report will appear here.', style: theme.textTheme.bodyMedium),
            if (order.reporter != null) ...[
              const SizedBox(height: 8),
              Text('Reported by ${order.reporter!.fullName}', style: theme.textTheme.bodySmall),
            ],
            if (order.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Files', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              AttachmentList(files: order.attachments),
            ],
          ],
        ),
      ),
    );
  }
}
