import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/documents/document_text.dart';

/// "Open PDF" and "Download" for a record's branded PDF (made on the server). The phone's own viewer or browser
/// opens a short-lived signed link; after the first use the document's code and file name show underneath.
class DocumentButtons extends ConsumerStatefulWidget {
  const DocumentButtons({super.key, required this.type, required this.recordId});

  final DocumentType type;
  final String recordId;

  @override
  ConsumerState<DocumentButtons> createState() => _DocumentButtonsState();
}

class _DocumentButtonsState extends ConsumerState<DocumentButtons> {
  bool _busy = false;
  GeneratedDocument? _document;

  Future<void> _go({required bool download}) async {
    setState(() => _busy = true);
    try {
      final document = await ref.read(documentRepositoryProvider).info(widget.type, widget.recordId);
      if (mounted) setState(() => _document = document);
      final url = Uri.parse(download ? document.downloadUrl : document.openUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw const ApiException(status: 0, code: ErrorCodes.unexpected, message: DocumentText.noViewer);
      }
    } catch (error) {
      if (mounted) AppSnack.error(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = _document;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: DocumentText.open,
                icon: Icons.picture_as_pdf_rounded,
                variant: ButtonVariant.tonal,
                expand: true,
                onPressed: _busy ? null : () => _go(download: false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: DocumentText.download,
                icon: Icons.download_rounded,
                variant: ButtonVariant.outlined,
                expand: true,
                onPressed: _busy ? null : () => _go(download: true),
              ),
            ),
          ],
        ),
        if (document != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              DocumentText.saved(document.code, document.fileName, document.size),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
