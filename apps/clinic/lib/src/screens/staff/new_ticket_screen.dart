import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/staff/ticket_text.dart';
import '../../controllers/staff/support_actions.dart';
import '../../widgets/common/attach_photo_button.dart';

part 'new_ticket_screen_photo_picks.dart';
part 'new_ticket_screen_tone_choices.dart';

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
    final ticket = await SupportActions.open(
      ref,
      subject: _subject.text.trim(),
      description: _description.text.trim(),
      category: _category,
      priority: _priority,
      photos: [for (final p in _photos) (path: p.path, name: p.name)],
      onPhotosFailed: (e) => mounted ? AppSnack.error(context, e) : null,
    );
    if (mounted) {
      AppSnack.success(context, '${ticket.code} opened — the support team is told.');
      context.pop(ticket);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(TicketText.newSupportTicket)),
      body: Form(
        key: _form,
        autovalidateMode: _tried ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(TicketText.newTicketHint, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subject,
              maxLength: 150,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: TicketText.subject,
                hintText: TicketText.subjectHint,
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v?.trim().length ?? 0) < 4 ? TicketText.subjectTooShort : null,
            ),
            const SectionHeader(TicketText.category),
            _ToneChoices(
              enumName: 'TicketCategory',
              values: _categories,
              selected: _category,
              onSelected: (v) => setState(() => _category = v),
            ),
            const SectionHeader(TicketText.priority),
            _ToneChoices(
              enumName: 'TreatmentPriority',
              values: _priorities,
              selected: _priority,
              onSelected: (v) => setState(() => _priority = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 8,
              maxLength: 5000,
              decoration: const InputDecoration(
                labelText: TicketText.whatHappened,
                hintText: TicketText.whatHappenedHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v?.trim().length ?? 0) < 10 ? TicketText.descriptionTooShort : null,
            ),
            const SizedBox(height: 4),
            _PhotoPicks(
              photos: _photos,
              onAdd: (photo) => setState(() => _photos.add(photo)),
              onRemove: (photo) => setState(() => _photos.remove(photo)),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: TicketText.openTicket,
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
