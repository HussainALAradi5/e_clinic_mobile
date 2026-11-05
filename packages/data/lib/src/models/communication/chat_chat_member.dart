part of 'chat.dart';

/// Mirror of ParticipantResource.
@freezed
abstract class ChatMember with _$ChatMember {
  const factory ChatMember({
    required String userId,
    required String fullName,
    String? avatarUrl,
    required String role,

    /// `online` / `offline` in chat.
    String? presence,
    @Default(false) bool isMe,
    DateTime? lastReadAt,

    /// Work contact of a colleague (chat info).
    String? phone,
    String? email,
  }) = _ChatMember;

  factory ChatMember.fromJson(Map<String, dynamic> json) => _$ChatMemberFromJson(json);
}
