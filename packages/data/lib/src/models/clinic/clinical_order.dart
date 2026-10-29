import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/clinic/clinical_order_type.dart';
import '../../enums/shared/generic_status.dart';
import '../shared/refs.dart';

part 'clinical_order.freezed.dart';
part 'clinical_order.g.dart';

/// A stored file (Identity › Attachments).
@freezed
abstract class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
    String? scanStatus,
  }) = _Attachment;

  const Attachment._();

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  bool get isImage => mimeType.startsWith('image/');

  /// `1.2 MB`.
  String get size {
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = sizeBytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }
}

/// Mirror of ClinicalOrderResource — a test, scan or referral. Patients see the report once it is completed.
@freezed
abstract class ClinicalOrder with _$ClinicalOrder {
  const factory ClinicalOrder({
    required String id,
    required String code,
    @JsonKey(unknownEnumValue: ClinicalOrderType.unknown) required ClinicalOrderType type,
    required String description,
    PersonRef? orderingDoctor,
    @JsonKey(unknownEnumValue: GenericStatus.unknown) required GenericStatus status,
    DateTime? completedAt,
    String? report,
    PersonRef? reporter,
    bool? isAbnormal,
    @Default([]) List<Attachment> attachments,
  }) = _ClinicalOrder;

  factory ClinicalOrder.fromJson(Map<String, dynamic> json) => _$ClinicalOrderFromJson(json);
}

/// A short-lived signed link to a file (GET /attachments/{id}/download).
@freezed
abstract class SignedLink with _$SignedLink {
  const factory SignedLink({required String url, String? expiresAt}) = _SignedLink;

  factory SignedLink.fromJson(Map<String, dynamic> json) => _$SignedLinkFromJson(json);
}
