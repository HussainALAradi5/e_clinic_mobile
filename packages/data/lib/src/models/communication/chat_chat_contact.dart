part of 'chat.dart';

/// A colleague to start a chat with (`GET /chat/contacts`).
@freezed
abstract class ChatContact with _$ChatContact {
  const factory ChatContact({
    required String id,
    required String fullName,
    String? avatarUrl,
    String? userType,
    String? presence,
  }) = _ChatContact;

  factory ChatContact.fromJson(Map<String, dynamic> json) => _$ChatContactFromJson(json);
}
