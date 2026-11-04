import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Documents\DocumentType — a record that downloads as a branded PDF
/// (`GET /documents/{wire}/{id}`).
@JsonEnum(valueField: 'wire')
enum DocumentType {
  sickLeave('sick_leave'),
  prescription('prescription'),
  result('result'),
  consent('consent'),
  invoice('invoice'),
  receipt('receipt'),
  insuranceClaim('insurance_claim'),
  payslip('payslip'),
  zReport('z_report'),
  attendanceSlip('attendance_slip'),
  writtenDocument('written_document');

  const DocumentType(this.wire);

  /// The value in API paths and JSON.
  final String wire;
}
