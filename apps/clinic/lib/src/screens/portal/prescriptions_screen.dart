import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/common/common_text.dart';
import '../../constants/portal/prescription_text.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/prescriptions/prescription_card.dart';

/// `/prescriptions` — medicines with how to take them; open ones carry the code for the pharmacy.
class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text(CommonText.myPrescriptions)),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(prescriptionsProvider.future),
      child: AsyncBody(
        value: ref.watch(prescriptionsProvider),
        onRetry: () => ref.invalidate(prescriptionsProvider),
        data: (list) => list.isEmpty
            ? ListView(
                children: const [
                  EmptyState(
                    icon: Icons.medication_outlined,
                    title: PrescriptionText.noPrescriptions,
                    message: PrescriptionText.noPrescriptionsHint,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => PrescriptionCard(rx: list[i]),
              ),
      ),
    ),
  );
}
