part of 'dispensation.dart';

/// One medicine handed over or given.
@freezed
abstract class DispensationItem with _$DispensationItem {
  const factory DispensationItem({
    required String id,
    required MedicationRef medication,
    BatchRef? batch,
    required String quantity,
    Money? lineTotal,
  }) = _DispensationItem;

  factory DispensationItem.fromJson(Map<String, dynamic> json) => _$DispensationItemFromJson(json);
}
