import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

/// Up to three optional emergency contacts: each row has a name, a relation and a phone (the phone is needed once a
/// row is added), a remove button, and "Add a contact" until there are three. [onChanged] gets the rows as
/// contacts; [errorFor] shows the server's message for a field (`emergency_contacts.0.phone`).
class EmergencyContactsEditor extends StatefulWidget {
  const EmergencyContactsEditor({super.key, required this.initial, required this.onChanged, this.errorFor});

  final List<EmergencyContact> initial;
  final ValueChanged<List<EmergencyContact>> onChanged;
  final String? Function(String key)? errorFor;

  @override
  State<EmergencyContactsEditor> createState() => _EmergencyContactsEditorState();
}

class _EmergencyContactsEditorState extends State<EmergencyContactsEditor> {
  late final _rows = [for (final c in widget.initial) _row(c)];

  ({TextEditingController name, TextEditingController relation, TextEditingController phone}) _row([
    EmergencyContact? c,
  ]) => (
    name: TextEditingController(text: c?.name),
    relation: TextEditingController(text: c?.relation),
    phone: TextEditingController(text: c?.phone),
  );

  @override
  void dispose() {
    for (final r in _rows) {
      for (final c in [r.name, r.relation, r.phone]) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _changed() {
    String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    widget.onChanged([
      for (final r in _rows)
        EmergencyContact(name: text(r.name), relation: text(r.relation), phone: r.phone.text.trim()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration field(String label, String key, IconData icon) =>
        InputDecoration(labelText: label, prefixIcon: Icon(icon), errorText: widget.errorFor?.call(key));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Emergency contacts', style: Theme.of(context).textTheme.titleSmall),
        Text('Optional, up to three.', style: Theme.of(context).textTheme.bodySmall),
        for (final (i, r) in _rows.indexed) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('Contact ${i + 1}', style: Theme.of(context).textTheme.labelLarge)),
              IconButton(
                tooltip: 'Remove this contact',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  final removed = _rows.removeAt(i);
                  setState(() {});
                  _changed();
                  // The fields of the removed row go once the frame without them is built.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    for (final c in [removed.name, removed.relation, removed.phone]) {
                      c.dispose();
                    }
                  });
                },
              ),
            ],
          ),
          TextFormField(
            controller: r.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => _changed(),
            decoration: field('Name', 'emergency_contacts.$i.name', Icons.person_outline_rounded),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: r.relation,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => _changed(),
            decoration: field(
              'Relation (e.g. wife, son)',
              'emergency_contacts.$i.relation',
              Icons.diversity_1_outlined,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: r.phone,
            keyboardType: TextInputType.phone,
            onChanged: (_) => _changed(),
            validator: (v) => (v ?? '').trim().length < 8 ? 'Enter the phone number with the country code.' : null,
            decoration: field('Phone', 'emergency_contacts.$i.phone', Icons.call_outlined),
          ),
        ],
        if (_rows.length < EmergencyContact.max) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() => _rows.add(_row()));
                _changed();
              },
              icon: const Icon(Icons.person_add_alt_rounded),
              label: const Text('Add a contact'),
            ),
          ),
        ],
      ],
    );
  }
}
