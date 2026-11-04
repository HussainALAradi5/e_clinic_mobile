import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

part 'chat_chat_contact.dart';
part 'chat_chat_file.dart';
part 'chat_chat_member.dart';
part 'chat_chat_message.dart';
part 'chat_chat_reaction.dart';
part 'chat_chat_reply_quote.dart';
part 'chat_chat_sender.dart';

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

    /// I muted this chat: no badge or alerts from it (mentions still notify).
    @Default(false) bool muted,

    /// When my mute ends by itself; null = until I unmute.
    DateTime? mutedUntil,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  const Conversation._();

  bool get isGroup => type == 'group';

  bool get iLead => myRole == 'admin';

  /// Either person deletes a one-to-one chat; a group only its leader.
  bool get canDelete => deletedAt == null && (!isGroup || iLead);

  DateTime? get activity => lastMessageAt ?? createdAt;
}
