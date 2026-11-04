import 'dart:typed_data';

import 'package:e_clinic_core/core.dart';

/// The signed-in staff member's signature (drawn or uploaded), printed on the documents they issue.
class SignatureRepository {
  const SignatureRepository(this._api);

  final ApiClient _api;

  static const _path = 'auth/signature';

  /// The signature image, or null while there is none.
  Future<Uint8List?> current() => _api.bytes(_path);

  /// Saves a PNG / JPEG (≤ 1 MB), replacing the previous one; patients get 403 `SIGNATURE_STAFF_ONLY`.
  Future<void> save(List<int> image, String fileName) =>
      _api.uploadBytes(_path, ApiClient.ignore, field: 'signature', bytes: image, fileName: fileName);

  Future<void> remove() => _api.delete(_path);
}
