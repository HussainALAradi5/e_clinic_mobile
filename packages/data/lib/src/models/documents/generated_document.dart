import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_document.freezed.dart';
part 'generated_document.g.dart';

/// A record's current PDF (GET /documents/{type}/{id}): its DOC code, unique file name, size, and short-lived signed
/// links the phone's viewer or browser opens without signing in.
@freezed
abstract class GeneratedDocument with _$GeneratedDocument {
  const factory GeneratedDocument({
    required String id,
    required String code,
    required String fileName,
    required int sizeBytes,
    required String openUrl,
    required String downloadUrl,
    String? reference,
  }) = _GeneratedDocument;

  const GeneratedDocument._();

  factory GeneratedDocument.fromJson(Map<String, dynamic> json) => _$GeneratedDocumentFromJson(json);

  /// "41 KB".
  String get size => '${(sizeBytes / 1024).ceil()} KB';
}
