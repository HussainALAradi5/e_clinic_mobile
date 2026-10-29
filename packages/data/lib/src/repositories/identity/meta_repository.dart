import 'package:e_clinic_core/core.dart';

import '../../models/shared/enum_catalog.dart';

/// Labels of every enum (loaded once per session).
class MetaRepository {
  const MetaRepository(this._api);

  final ApiClient _api;

  Future<EnumCatalog> enums() => _api.get('meta/enums', EnumCatalog.fromJson);
}
