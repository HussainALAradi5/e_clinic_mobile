import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-size signed QR code of a record, to be scanned at the front desk or the pharmacy.
Future<void> showCodeSheet(
  BuildContext context, {
  required String entity,
  required String id,
  required String title,
  required List<String> lines,
  required String hint,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CodeSheet(entity: entity, id: id, title: title, lines: lines, hint: hint),
    );

class _CodeSheet extends ConsumerWidget {
  const _CodeSheet({required this.entity, required this.id, required this.title, required this.lines, required this.hint});

  final String entity;
  final String id;
  final String title;
  final List<String> lines;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final base = ref.watch(apiClientProvider).baseUrl;
    final token = ref.watch(tokenStoreProvider).current;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Codes scan best dark on white, also in dark mode.
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Image.network(
                '$base/codes/$entity/$id?format=png&size=512',
                headers: {if (token != null) 'Authorization': 'Bearer $token'},
                width: 240,
                height: 240,
                semanticLabel: '$title QR code',
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox.square(dimension: 240, child: Center(child: CircularProgressIndicator())),
                errorBuilder: (context, error, stack) => SizedBox.square(
                  dimension: 240,
                  child: Center(
                    child: Text(
                      'Could not load the code. Check your connection.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final line in lines)
              Text(line, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
