import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone, email and emergency contact (PUT /portal/profile).
class ContactSheet extends ConsumerStatefulWidget {
  const ContactSheet({super.key, required this.patient});

  final Patient patient;

  @override
  ConsumerState<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends ConsumerState<ContactSheet> {
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
