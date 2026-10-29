import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_timeline_entry.freezed.dart';
part 'patient_timeline_entry.g.dart';

/// One event in a patient file (GET /patients/{id}/timeline): a visit, treatment or order, newest first.
@freezed
abstract class PatientTimelineEntry with _$PatientTimelineEntry {
  const factory PatientTimelineEntry({
    /// `appointment`, `treatment` or `order`.
    required String kind,
    required String id,
    required DateTime at,
    required String title,
    String? status,
  }) = _PatientTimelineEntry;

  factory PatientTimelineEntry.fromJson(Map<String, dynamic> json) => _$PatientTimelineEntryFromJson(json);
}
