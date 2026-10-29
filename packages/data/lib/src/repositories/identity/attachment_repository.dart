import 'package:e_clinic_core/core.dart';
import '../../models/clinic/clinical_order.dart';

/// Attachments — files open through short-lived signed links.
class AttachmentRepository {
  const AttachmentRepository(this._api);

  final ApiClient _api;

  Future<SignedLink> downloadLink(String id, {bool inline = true}) =>
      _api.get('attachments/$id/download', objectOf(SignedLink.fromJson), query: {if (inline) 'inline': 1});
}
