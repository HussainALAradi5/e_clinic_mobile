import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/portal_providers.dart';
import '../portal_paths.dart';
import '../widgets/profile/contact_sheet.dart';

/// `/profile` — the patient's file as the clinic holds it. Contact details and the emergency contact can be changed
/// here; name, ID and insurance change at the front desk (they need documents).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: AsyncBody(
        value: ref.watch(profileProvider),
        onRetry: () => ref.invalidate(profileProvider),
        data: (p) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              ProfileHeader(name: p.fullName, lines: ['Patient number ${p.code}']),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusChip(enumName: 'Gender', value: p.gender),
                  if (p.person.nationality case final n?) FlagBadge(countryCode: n.code, label: n.nationality),
                ],
              ),
              const SectionHeader('Personal'),
              Card(
                child: FactList(
                  facts: [
                    (label: 'Date of birth', value: ClinicClock.date(p.dateOfBirth)),
                    (label: 'ID number', value: p.person.nationalId),
                  ],
                ),
              ),
              SectionHeader(
                'Contact',
                trailing: TextButton.icon(
                  onPressed: () => _editContact(context, ref, p),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              Card(
                child: FactList(
                  facts: [
                    (label: 'Mobile', value: p.phone),
                    (label: 'Email', value: p.email),
                    (label: 'Address', value: p.person.address?.formatted),
                    (
                      label: 'Emergency contact',
                      value: [
                        p.emergencyContactName,
                        p.emergencyContactRelation,
                        p.emergencyContactPhone,
                      ].whereType<String>().where((v) => v.isNotEmpty).join(' · '),
                    ),
                  ],
                ),
              ),
              if (p.insurer != null) ...[
                const SectionHeader('Insurance'),
                Card(
                  child: FactList(
                    facts: [
                      (label: 'Insurer', value: p.insurer!.name),
                      (label: 'Policy number', value: p.insurancePolicyNumber),
                      (
                        label: 'Covers',
                        value: p.insuranceCoveragePercent == null
                            ? null
                            : '${double.tryParse(p.insuranceCoveragePercent!)?.round() ?? p.insuranceCoveragePercent} %',
                      ),
                      (
                        label: 'Valid until',
                        value: p.insuranceExpiryDate == null ? null : ClinicClock.date(p.insuranceExpiryDate!),
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: Text(
                  'To change your name, ID or insurance, visit the front desk with your documents.',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
              const ThemeModeTile(),
              const SectionHeader('More'),
              LinkGroup(
                links: [
                  LinkTile(
                    icon: Icons.self_improvement_rounded,
                    label: 'My treatments',
                    onTap: () => context.push(PortalPaths.treatments),
                  ),
                  LinkTile(
                    icon: Icons.medication_outlined,
                    label: 'My prescriptions',
                    onTap: () => context.push(PortalPaths.prescriptions),
                  ),
                  LinkTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Messages',
                    onTap: () => context.push(PortalPaths.messages),
                  ),
                  LinkTile(
                    icon: Icons.shield_outlined,
                    label: 'Password & security',
                    onTap: () => context.push(AuthPaths.security),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                variant: ButtonVariant.outlined,
                expand: true,
                confirm: const ConfirmConfig(title: 'Sign out of e-Clinic?', confirmLabel: 'Sign out'),
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
    if (context.mounted) AppSnack.success(context, 'Your details are saved.');
  }
}
