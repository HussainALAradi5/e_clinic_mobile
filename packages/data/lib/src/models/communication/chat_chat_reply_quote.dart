part of 'chat.dart';

/// The message a reply quotes (null once the quoted message is gone).
@freezed
abstract class ChatReplyQuote with _$ChatReplyQuote {
  const factory ChatReplyQuote({
    required String id,
    required String senderId,
    required String senderName,
    required String kind,
    @Default('') String excerpt,
    String? fileName,
  }) = _ChatReplyQuote;

  factory ChatReplyQuote.fromJson(Map<String, dynamic> json) => _$ChatReplyQuoteFromJson(json);
}
