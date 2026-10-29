import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/portal_actions.dart';
import '../../application/portal_providers.dart';

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
              for (final file in order.attachments)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(file.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined),
                  title: Text(file.originalName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(file.size),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () async {
                    try {
                      await PortalActions.openFile(ref, file);
                    } catch (error) {
                      if (context.mounted) AppSnack.error(context, error);
                    }
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
