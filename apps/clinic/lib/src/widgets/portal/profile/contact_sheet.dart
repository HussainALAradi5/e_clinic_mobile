import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'emergency_contacts_editor.dart';

/// Phone, email and up to three emergency contacts (PUT /portal/profile).
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
  late var _contacts = widget.patient.emergencyContacts;
  ApiException? _error;

  @override
  void dispose() {
    for (final c in [_phone, _email]) {
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
            emergencyContacts: _contacts,
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
              EmergencyContactsEditor(
                initial: widget.patient.emergencyContacts,
                onChanged: (contacts) => _contacts = contacts,
                errorFor: (key) => _error?.fieldError(key),
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
