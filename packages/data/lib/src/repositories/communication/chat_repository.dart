import 'package:e_clinic_core/core.dart';

import '../../models/communication/chat.dart';

part 'chat_repository_chat_filter.dart';

/// Staff chat: my chats (filtered and paged on the server), messages 50 at a time going back, sending text and
/// photos (optionally as a reply), reactions, read receipts, starting a chat and soft-deleting one.
class ChatRepository {
  const ChatRepository(this._api);

  final ApiClient _api;

  static const _path = 'chat';

  /// Messages come in pages of this size (the server's page size).
  static const messagesPage = 50;

  Future<Paged<Conversation>> conversations({int page = 1, String? search, ChatFilter filter = ChatFilter.all}) =>
      _api.list(
        '$_path/conversations',
        ListQuery(page: page, perPage: 30, search: search),
        Conversation.fromJson,
        extra: {
          'type': switch (filter) {
            ChatFilter.groups => 'group',
            ChatFilter.direct => 'direct',
            _ => null,
          },
          'read': filter == ChatFilter.unread ? 'unread' : null,
        },
      );

  Future<Conversation> conversation(String id) => _api.get('$_path/conversations/$id', objectOf(Conversation.fromJson));

  /// Newest first; [before] (a message id) loads the ones before it.
  Future<Paged<ChatMessage>> messages(String id, {String? before}) => _api.list(
    '$_path/conversations/$id/messages',
    const ListQuery(perPage: messagesPage),
    ChatMessage.fromJson,
    extra: {'before': before},
  );

  /// Text, and/or [photos]; [replyTo] quotes a message of the same chat.
  Future<ChatMessage> send(String id, {String? body, List<UploadFile> photos = const [], String? replyTo}) {
    final fields = <String, Object>{'body': ?body, 'reply_to_id': ?replyTo};
    return photos.isEmpty
        ? _api.post('$_path/conversations/$id/messages', objectOf(ChatMessage.fromJson), body: fields)
        : _api.upload(
            '$_path/conversations/$id/messages',
            objectOf(ChatMessage.fromJson),
            files: photos,
            fields: fields,
          );
  }

  /// Sets my reaction; the same emoji again (or null) takes it back.
  Future<ChatMessage> react(String conversationId, String messageId, String? emoji) => _api.post(
    '$_path/conversations/$conversationId/messages/$messageId/reactions',
    objectOf(ChatMessage.fromJson),
    body: {'emoji': emoji},
  );

  Future<void> markRead(String id) => _api.post('$_path/conversations/$id/read', ApiClient.ignore);

  /// Unread messages over all my chats.
  Future<int> unreadCount() =>
      _api.get('$_path/unread', (data) => ((data as Map<String, dynamic>?)?['count'] as num?)?.toInt() ?? 0);

  /// Colleagues to chat with.
  /// Colleagues matching the search (name, phone, email or staff no.), one page at a time; only people in the system.
  Future<Paged<ChatContact>> contacts({String? search, int page = 1, int perPage = 20}) =>
      _api.list('$_path/contacts', ListQuery(search: search, page: page, perPage: perPage), ChatContact.fromJson);

  /// The one-to-one chat with a colleague (created on first use, brought back if it was deleted).
  Future<Conversation> startDirect(String userId) =>
      _api.post('$_path/conversations', objectOf(Conversation.fromJson), body: {'type': 'direct', 'user_id': userId});

  /// Soft delete: it leaves the members' lists; an admin can restore it.
  Future<void> delete(String id) => _api.delete('$_path/conversations/$id');

  /// The quick reaction row and everything behind "+".
  Future<({List<String> quick, List<String> all})> reactions() => _api.get('$_path/settings', (data) {
    final map = data as Map<String, dynamic>? ?? const {};
    List<String> strings(Object? v) => [for (final e in v as List<dynamic>? ?? const []) e as String];
    return (quick: strings(map['reactions']), all: strings(map['all_reactions']));
  });
}
