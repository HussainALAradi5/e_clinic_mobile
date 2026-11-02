import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

/// Mirror of ConversationResource — one chat in my list: a one-to-one chat (titled with the other person) or a
/// group. `myRole` is `admin` (leader) or `member`; deleted chats carry `deletedAt` (admins only see them).
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String type,
    required String title,
    String? partnerId,
    String? avatarUrl,
    String? myRole,
    @Default(<ChatMember>[]) List<ChatMember> members,
    ChatMessage? lastMessage,
    @Default(0) int unreadCount,
    int? messagesCount,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  const Conversation._();

  bool get isGroup => type == 'group';

  bool get iLead => myRole == 'admin';

  /// Either person deletes a one-to-one chat; a group only its leader.
  bool get canDelete => deletedAt == null && (!isGroup || iLead);

  DateTime? get activity => lastMessageAt ?? createdAt;
}

/// Mirror of ParticipantResource.
@freezed
abstract class ChatMember with _$ChatMember {
  const factory ChatMember({
    required String userId,
    required String fullName,
    String? avatarUrl,
    required String role,
    @Default(false) bool isMe,
    DateTime? lastReadAt,
  }) = _ChatMember;

  factory ChatMember.fromJson(Map<String, dynamic> json) => _$ChatMemberFromJson(json);
}

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

@freezed
abstract class ChatSender with _$ChatSender {
  const factory ChatSender({required String id, required String fullName, String? avatarUrl, String? role}) =
      _ChatSender;

  factory ChatSender.fromJson(Map<String, dynamic> json) => _$ChatSenderFromJson(json);
}

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

@freezed
abstract class ChatReaction with _$ChatReaction {
  const factory ChatReaction({
    required String emoji,
    required int count,
    @Default(<String>[]) List<String> userIds,
    @Default(<String>[]) List<String> names,
  }) = _ChatReaction;

  factory ChatReaction.fromJson(Map<String, dynamic> json) => _$ChatReactionFromJson(json);
}

/// A colleague to start a chat with (`GET /chat/contacts`).
@freezed
abstract class ChatContact with _$ChatContact {
  const factory ChatContact({required String id, required String fullName, String? avatarUrl, String? userType}) =
      _ChatContact;

  factory ChatContact.fromJson(Map<String, dynamic> json) => _$ChatContactFromJson(json);
}
