import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/common/common_text.dart';

/// Attaches a photo (camera or gallery) to a record: picks first, then locks for the upload only. The server checks
/// the type, size and virus scan, and keeps the file private.
class AttachPhotoButton extends ConsumerStatefulWidget {
  const AttachPhotoButton({
    super.key,
    required this.ownerType,
    required this.ownerId,
    required this.category,
    required this.onUploaded,
    this.label = CommonText.addPhotoShort,
    this.variant = ButtonVariant.outlined,
    this.expand = false,
  });

  /// `clinical_order`, `leave_request` …
  final String ownerType;
  final String ownerId;
  final AttachmentCategory category;
  final ValueChanged<List<Attachment>> onUploaded;
  final String label;
  final ButtonVariant variant;
  final bool expand;

  @override
  ConsumerState<AttachPhotoButton> createState() => _AttachPhotoButtonState();
}

class _AttachPhotoButtonState extends ConsumerState<AttachPhotoButton> {
  XFile? _photo;

  Future<bool> _pick() async {
    _photo = await pickPhoto(context);
    return _photo != null;
  }

  Future<void> _upload() async {
    final photo = _photo;
    if (photo == null) throw const ActionCancelled();
    final saved = await ref
        .read(attachmentRepositoryProvider)
        .upload(
          ownerType: widget.ownerType,
          ownerId: widget.ownerId,
          category: widget.category,
          files: [(path: photo.path, name: photo.name)],
        );
    if (saved.isEmpty) {
      throw const ApiException(status: 422, code: ErrorCodes.unexpected, message: CommonText.photoRefused);
    }
    widget.onUploaded(saved);
    if (mounted) AppSnack.success(context, CommonText.photoAttached);
  }

  @override
  Widget build(BuildContext context) => AppButton(
    label: widget.label,
    icon: Icons.add_a_photo_outlined,
    variant: widget.variant,
    expand: widget.expand,
    before: _pick,
    onPressed: _upload,
  );
}

/// Camera or gallery, then the photo (resized for upload); null when the user backs out.
Future<XFile?> pickPhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text(CommonText.takePhoto),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text(CommonText.chooseFromGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2400);
}
