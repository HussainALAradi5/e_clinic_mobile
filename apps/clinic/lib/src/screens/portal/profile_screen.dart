import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/common/common_text.dart';
import '../../constants/portal/profile_text.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/profile/contact_sheet.dart';
import '../../widgets/portal/profile/insurance_card.dart';
import '../../widgets/portal/profile/profile_links.dart';

/// `/profile` — the patient's file as the clinic holds it. Contact details and up to three emergency contacts can be changed
/// here; name, ID and insurance change at the front desk (they need documents).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileText.myProfile)),
      body: AsyncBody(
        value: ref.watch(profileProvider),
        onRetry: () => ref.invalidate(profileProvider),
        data: (p) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              ProfileHeader(name: p.fullName, lines: [ProfileText.patientNumber(p.code)]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusChip(enumName: 'Gender', value: p.gender),
                  if (p.person.nationality case final n?) FlagBadge(countryCode: n.code, label: n.nationality),
                ],
              ),
              const SectionHeader(ProfileText.personal),
              Card(
                child: FactList(
                  facts: [
                    (label: CommonText.dateOfBirth, value: ClinicClock.date(p.dateOfBirth)),
                    (label: CommonText.idNumber, value: p.person.nationalId),
                  ],
                ),
              ),
              SectionHeader(
                ProfileText.contact,
                trailing: TextButton.icon(
                  onPressed: () => _editContact(context, ref, p),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(ProfileText.edit),
                ),
              ),
              Card(
                child: FactList(
                  facts: [
                    (label: CommonText.mobile, value: p.phone),
                    (label: CommonText.email, value: p.email),
                    (label: CommonText.address, value: p.person.address?.formatted),
                    (label: CommonText.emergencyContacts, value: p.emergencyContacts.map((c) => c.line).join('\n')),
                  ],
                ),
              ),
              if (p.insurer != null) ...[const SectionHeader(ProfileText.insurance), InsuranceCard(patient: p)],
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: Text(
                  ProfileText.frontDeskChanges,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
              const ThemeModeTile(),
              const TimeFormatTile(),
              const PhoneNotificationsTile(),
              const SectionHeader(CommonText.more),
              const ProfileLinks(),
              const SizedBox(height: 24),
              AppButton(
                label: CommonText.signOut,
                icon: Icons.logout_rounded,
                variant: ButtonVariant.outlined,
                expand: true,
                confirm: const ConfirmConfig(title: CommonText.signOutConfirm, confirmLabel: CommonText.signOut),
                onPressed: () => ref.read(sessionProvider.notifier).logout(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editContact(BuildContext context, WidgetRef ref, Patient patient) async {
    final saved = await showModalBottomSheet<Patient>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ContactSheet(patient: patient),
    );
    if (saved == null) return;
    ref.read(profileProvider.notifier).replace(saved);
    if (context.mounted) AppSnack.success(context, ProfileText.saved);
  }
}
