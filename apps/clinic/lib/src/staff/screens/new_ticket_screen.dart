import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/widgets/attach_photo_button.dart';

/// `/support/tickets/new` — report a problem: subject, category, priority and what happened. Closes with the new
/// ticket; the support team is told right away.
class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  static const _categories = ['technical', 'access', 'equipment', 'data', 'other'];
  static const _priorities = ['medium', 'high', 'urgent'];

  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  var _category = 'technical';
  var _priority = 'medium';
  var _tried = false;
  final _photos = <XFile>[];

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) {
      // Show the errors as the fields change from now on; the button unlocks for another try.
      setState(() => _tried = true);
      throw const ActionCancelled();
    }
    final ticket = await ref
        .read(ticketRepositoryProvider)
        .open(
          subject: _subject.text.trim(),
          description: _description.text.trim(),
          category: _category,
          priority: _priority,
        );
    if (_photos.isNotEmpty) {
      try {
        await ref
            .read(attachmentRepositoryProvider)
            .upload(
              ownerType: 'support_ticket',
              ownerId: ticket.id,
              category: AttachmentCategory.ticketAttachment,
              files: [for (final p in _photos) (path: p.path, name: p.name)],
            );
      } on ApiException catch (e) {
        // The ticket is open either way; photos can be added on its page.
        if (mounted) AppSnack.error(context, e);
      }
    }
    if (mounted) {
      AppSnack.success(context, '${ticket.code} opened — the support team is told.');
      context.pop(ticket);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final theme = Theme.of(context);
    Widget choices(String enumName, List<String> values, String selected, ValueChanged<String> onSelected) => Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(catalog.label(enumName, v)),
            selected: v == selected,
            onSelected: (_) => onSelected(v),
          ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('New support ticket')),
      body: Form(
        key: _form,
        autovalidateMode: _tried ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              'You get a notification when it is picked up and when it is solved.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subject,
              maxLength: 150,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g. Label printer in ward 2 is offline',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v?.trim().length ?? 0) < 4 ? 'At least 4 characters.' : null,
            ),
            const SectionHeader('Category'),
            choices('TicketCategory', _categories, _category, (v) => setState(() => _category = v)),
            const SectionHeader('Priority'),
            choices('TreatmentPriority', _priorities, _priority, (v) => setState(() => _priority = v)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 8,
              maxLength: 5000,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                hintText: 'Where, since when, what you already tried',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v?.trim().length ?? 0) < 10 ? 'At least 10 characters.' : null,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final photo in _photos)
                  InputChip(
                    avatar: const Icon(Icons.image_outlined, size: 18),
                    label: Text(photo.name, overflow: TextOverflow.ellipsis),
                    onDeleted: () => setState(() => _photos.remove(photo)),
                  ),
                if (_photos.length < 5)
                  TextButton.icon(
                    onPressed: () async {
                      final photo = await pickPhoto(context);
                      if (photo != null) setState(() => _photos.add(photo));
                    },
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(_photos.isEmpty ? 'Add a photo or screenshot' : 'Add another'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Open ticket',
              icon: Icons.send_rounded,
              expand: true,
              lock: ButtonLock.once,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
