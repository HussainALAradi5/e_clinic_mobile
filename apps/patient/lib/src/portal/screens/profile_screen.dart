import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/portal_providers.dart';
import '../portal_paths.dart';

/// `/profile` — the patient's file as the clinic holds it. Contact details and the emergency contact can be changed
/// here; name, ID and insurance change at the front desk (they need documents).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
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
              const SectionHeader('Personal'),
              Card(
                child: FactList(
                  facts: [
                    (label: 'Date of birth', value: ClinicClock.date(p.dateOfBirth)),
                    (label: 'Gender', value: catalog.label('Gender', p.gender)),
                    (label: 'Nationality', value: p.person.nationality?.nationality),
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
      builder: (_) => _ContactSheet(patient: patient),
    );
    if (saved == null) return;
    ref.read(profileProvider.notifier).replace(saved);
    if (context.mounted) AppSnack.success(context, 'Your details are saved.');
  }
}

/// Phone, email and emergency contact (PUT /portal/profile).
class _ContactSheet extends ConsumerStatefulWidget {
  const _ContactSheet({required this.patient});

  final Patient patient;

  @override
  ConsumerState<_ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends ConsumerState<_ContactSheet> {
  final _form = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: widget.patient.phone);
  late final _email = TextEditingController(text: widget.patient.email);
  late final _contactName = TextEditingController(text: widget.patient.emergencyContactName);
  late final _contactRelation = TextEditingController(text: widget.patient.emergencyContactRelation);
  late final _contactPhone = TextEditingController(text: widget.patient.emergencyContactPhone);
  ApiException? _error;

  @override
  void dispose() {
    for (final c in [_phone, _email, _contactName, _contactRelation, _contactPhone]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _blankToNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) throw const ActionCancelled();
    final p = widget.patient;
    try {
      final saved = await ref
          .read(portalRepositoryProvider)
          .updateProfile(
            version: p.version,
            personVersion: p.person.version,
            phone: _phone.text.trim(),
            email: _blankToNull(_email),
            emergencyContactName: _blankToNull(_contactName),
            emergencyContactPhone: _blankToNull(_contactPhone),
            emergencyContactRelation: _blankToNull(_contactRelation),
          );
      if (mounted) Navigator.of(context).pop(saved);
    } on ApiException catch (error) {
      if (error.code == ErrorCodes.validationFailed && mounted) {
        setState(() => _error = error);
        throw const ActionCancelled();
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration field(String label, String key, IconData icon) =>
        InputDecoration(labelText: label, prefixIcon: Icon(icon), errorText: _error?.fieldError(key));
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Contact details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: field('Mobile', 'phone', Icons.phone_iphone_rounded),
                validator: (v) =>
                    (v ?? '').trim().length < 8 ? 'Enter your mobile number with the country code.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: field('Email', 'email', Icons.mail_outline_rounded),
              ),
              const SizedBox(height: 20),
              Text('Emergency contact', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: field('Name', 'emergency_contact_name', Icons.person_outline_rounded),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactRelation,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: field(
                  'Relation (e.g. wife, son)',
                  'emergency_contact_relation',
                  Icons.diversity_1_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: field('Phone', 'emergency_contact_phone', Icons.call_outlined),
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Save', icon: Icons.check_rounded, expand: true, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
