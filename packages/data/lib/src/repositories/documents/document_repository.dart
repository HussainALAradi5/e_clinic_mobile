import 'package:e_clinic_core/core.dart';

import '../../enums/documents/document_type.dart';
import '../../models/documents/generated_document.dart';

/// Documents — the branded PDF of any record the user may read (made on the server on first use).
class DocumentRepository {
  const DocumentRepository(this._api);

  final ApiClient _api;

  /// The record's current PDF: code, file name and signed open / download links. 404 when it may not be read.
  Future<GeneratedDocument> info(DocumentType type, String id) =>
      _api.get('documents/${type.wire}/$id', objectOf(GeneratedDocument.fromJson));
}
