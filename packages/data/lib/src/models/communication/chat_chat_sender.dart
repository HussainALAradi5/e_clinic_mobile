part of 'chat.dart';

@freezed
abstract class ChatSender with _$ChatSender {
  const factory ChatSender({required String id, required String fullName, String? avatarUrl, String? role}) =
      _ChatSender;

  factory ChatSender.fromJson(Map<String, dynamic> json) => _$ChatSenderFromJson(json);
}
