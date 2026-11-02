part of 'chat.dart';

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
