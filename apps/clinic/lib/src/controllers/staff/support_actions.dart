import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Support ticket steps that span more than one call.
abstract final class SupportActions {
  /// Opens the ticket, then uploads its [photos]. The ticket is open either way: when the photos fail,
  /// [onPhotosFailed] gets the error (they can be added on the ticket's page).
  static Future<SupportTicket> open(
    WidgetRef ref, {
    required String subject,
    required String description,
    required String category,
    required String priority,
    required List<UploadFile> photos,
    required void Function(ApiException error) onPhotosFailed,
  }) async {
    final ticket = await ref
        .read(ticketRepositoryProvider)
        .open(subject: subject, description: description, category: category, priority: priority);
    if (photos.isNotEmpty) {
      try {
        await ref
            .read(attachmentRepositoryProvider)
            .upload(
              ownerType: 'support_ticket',
              ownerId: ticket.id,
              category: AttachmentCategory.ticketAttachment,
              files: photos,
            );
      } on ApiException catch (e) {
        onPhotosFailed(e);
      }
    }
    return ticket;
  }
}
