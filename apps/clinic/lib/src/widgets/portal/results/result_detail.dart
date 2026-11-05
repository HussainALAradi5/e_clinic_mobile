import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/portal/result_text.dart';
import '../../../controllers/portal/portal_providers.dart';
import '../../common/attachment_list.dart';
import '../../common/document_buttons.dart';

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
            Text(
              CommonText.report,
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            SelectableText(order.report ?? ResultText.reportPending, style: theme.textTheme.bodyMedium),
            if (order.reporter != null) ...[
              const SizedBox(height: 8),
              Text(CommonText.reportedBy(order.reporter!.fullName), style: theme.textTheme.bodySmall),
            ],
            if (order.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                ResultText.files,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              AttachmentList(files: order.attachments),
            ],
            const SizedBox(height: 16),
            DocumentButtons(type: DocumentType.result, recordId: order.id),
          ],
        ),
      ),
    );
  }
}
