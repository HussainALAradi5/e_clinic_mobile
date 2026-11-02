part of 'chat.dart';

/// Mirror of MessageResource — text, media (photos, files) or a voice note, the quote it answers, reactions.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String conversationId,
    required String kind,
    String? body,
    @Default(<String>[]) List<String> mentions,
    required ChatSender sender,
    ChatReplyQuote? replyTo,
    @Default(<ChatFile>[]) List<ChatFile> attachments,
    @Default(<ChatReaction>[]) List<ChatReaction> reactions,
    required DateTime createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  const ChatMessage._();

  /// My current reaction, if any.
  String? reactionOf(String userId) => reactions.where((r) => r.userIds.contains(userId)).firstOrNull?.emoji;
}
