import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Files of a record (images, PDFs); a tap opens one through a short-lived signed link in the phone's viewer.
class AttachmentList extends ConsumerWidget {
  const AttachmentList({super.key, required this.files});

  final List<Attachment> files;

  Future<void> _open(BuildContext context, WidgetRef ref, Attachment file) async {
    try {
      final link = await ref.read(attachmentRepositoryProvider).downloadLink(file.id);
      if (!await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication)) {
        throw const ApiException(
          status: 0,
          code: ErrorCodes.unexpected,
          message: 'No app on this phone can open the file.',
        );
      }
    } catch (error) {
      if (context.mounted) AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      for (final file in files)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(file.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined),
          title: Text(file.originalName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(file.size),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => _open(context, ref, file),
        ),
    ],
  );
}
