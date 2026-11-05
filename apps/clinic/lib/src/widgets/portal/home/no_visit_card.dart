import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/portal_paths.dart';
import '../../../constants/common/common_text.dart';
import '../../../constants/portal/visit_text.dart';

class NoVisitCard extends StatelessWidget {
  const NoVisitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(VisitText.noVisitsBooked, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                VisitText.bookingHint,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(PortalPaths.book),
                icon: const Icon(Icons.add_rounded),
                label: const Text(CommonText.bookVisit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
