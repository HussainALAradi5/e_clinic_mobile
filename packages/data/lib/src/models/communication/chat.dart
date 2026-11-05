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
/// group. `myRole` is `admin` (leader) or `member`; deleted chats carry `deletedAt` (admins only see them); `left`
/// marks a group I exited (read-only on my list until I delete it).
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String type,
    required String title,
    String? partnerId,

    /// The other person's `online` / `offline` status (one-to-one chats).
    String? partnerPresence,
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

    /// I exited this group: readable up to then, not writable.
    @Default(false) bool left,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  const Conversation._();

  bool get isGroup => type == 'group';

  bool get iLead => myRole == 'admin';

  /// Deleted from my list only: a one-to-one chat any time, a group once I exited it.
  bool get canDelete => deletedAt == null && (!isGroup || left);

  /// Still in this group (Exit is offered).
  bool get canLeave => isGroup && !left && deletedAt == null;

  bool get canMute => !left && deletedAt == null;

  bool get partnerOnline => partnerPresence == 'online';

  DateTime? get activity => lastMessageAt ?? createdAt;
}
