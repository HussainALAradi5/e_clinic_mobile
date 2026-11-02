part of 'clinical_order.dart';

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
