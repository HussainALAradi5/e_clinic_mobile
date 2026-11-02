part of 'chat.dart';

/// A file of a message; `url` is a signed link (null until the virus scan passed).
@freezed
abstract class ChatFile with _$ChatFile {
  const factory ChatFile({
    required String id,
    required String name,
    required String mimeType,
    @Default(0) int sizeBytes,
    String? url,
  }) = _ChatFile;

  factory ChatFile.fromJson(Map<String, dynamic> json) => _$ChatFileFromJson(json);

  const ChatFile._();

  bool get isImage => mimeType.startsWith('image/');
}
