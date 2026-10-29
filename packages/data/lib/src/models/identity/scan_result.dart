import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

/// What a scanned code points to (POST /codes/scan): the record type, its id and a few safe facts.
@freezed
abstract class ScanResult with _$ScanResult {
  const factory ScanResult({
    /// `appointment`, `person`, `prescription`, `clinical_order`, `invoice` …
    required String entity,
    required String id,
    required String code,
    @Default(true) bool valid,

    /// Fields set per entity on the server (`full_name`, `status`, `scheduled_date` …).
    @Default({}) Map<String, dynamic> summary,
  }) = _ScanResult;

  const ScanResult._();

  factory ScanResult.fromJson(Map<String, dynamic> json) => _$ScanResultFromJson(json);

  /// A summary field as text, or null when missing.
  String? text(String field) {
    final value = summary[field];
    return value == null || '$value'.isEmpty ? null : '$value';
  }
}
