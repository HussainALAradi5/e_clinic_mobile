import 'package:e_clinic_core/core.dart';
import '../../models/clinic/clinical_order.dart';

/// What a file is (AttachmentCategory): decides the allowed types and size on the server.
enum AttachmentCategory { xrayImage, labResult, clinicalDocument, referralLetter, medicalCertificate }

/// Attachments — files open through short-lived signed links.
class AttachmentRepository {
  const AttachmentRepository(this._api);

  final ApiClient _api;

  Future<SignedLink> downloadLink(String id, {bool inline = true}) =>
      _api.get('attachments/$id/download', objectOf(SignedLink.fromJson), query: {if (inline) 'inline': 1});

  /// Attaches [files] to a record (`clinical_order`, `leave_request` …) and returns the ones saved; files the
  /// server refuses (type, size, virus scan) come back as an error when none was saved.
  Future<List<Attachment>> upload({
    required String ownerType,
    required String ownerId,
    required AttachmentCategory category,
    required List<UploadFile> files,
  }) => _api.upload(
    'attachments',
    (data) => [
      for (final row in (data! as Map<String, dynamic>)['saved'] as List<dynamic>)
        Attachment.fromJson(row as Map<String, dynamic>),
    ],
    files: files,
    fields: {'attachable_type': ownerType, 'attachable_id': ownerId, 'category': wireValue(category)},
  );
}
