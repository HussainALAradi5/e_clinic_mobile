import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/foundation.dart';

import 'chat_providers.dart';

/// One open chat: the chat, its messages (newest first), older pages, polling for new ones, sending and reacting.
/// [onRead] runs whenever the chat is marked read (to refresh the unread count).
class ChatThreadController extends ChangeNotifier {
  ChatThreadController({required this.repo, required this.chatId, required this.onRead});

  final ChatRepository repo;
  final String chatId;
  final VoidCallback onRead;

  Conversation? chat;
  Object? error;
  var messages = <ChatMessage>[];
  var hasMore = false;
  var sending = false;
  var _loadingOlder = false;
  var _disposed = false;
  Timer? _poll;

  /// Loads the chat and starts asking for new messages every [chatPollEvery].
  void start() {
    unawaited(load());
    _poll = Timer.periodic(chatPollEvery, (_) => _fresh());
  }

  Future<void> load() async {
    try {
      final results = await Future.wait([repo.conversation(chatId), repo.messages(chatId)]);
      final page = results[1] as Paged<ChatMessage>;
      chat = results[0] as Conversation;
      messages = page.items;
      hasMore = page.hasMore;
      error = null;
      _changed();
      _markRead();
    } catch (e) {
      error = e;
      _changed();
    }
  }

  /// New messages (and reaction changes) since the newest page.
  Future<void> _fresh() async {
    if (chat == null || chat!.deletedAt != null) return;
    try {
      final page = await repo.messages(chatId);
      final latest = {for (final m in page.items) m.id: m};
      final known = messages.map((m) => m.id).toSet();
      final added = page.items.where((m) => !known.contains(m.id)).length;
      messages = [...page.items, ...messages.where((m) => !latest.containsKey(m.id))];
      _changed();
      if (added > 0) _markRead();
    } catch (_) {
      // Quiet: the next tick tries again.
    }
  }

  /// The next older page, once per scroll to the top.
  void loadOlder() {
    if (!hasMore || _loadingOlder || messages.isEmpty) return;
    _loadingOlder = true;
    repo
        .messages(chatId, before: messages.last.id)
        .then((page) {
          messages = [...messages, ...page.items];
          hasMore = page.hasMore;
          _changed();
        })
        .whenComplete(() => _loadingOlder = false);
  }

  void _markRead() {
    if (_disposed || chat?.deletedAt != null) return;
    unawaited(repo.markRead(chatId).catchError((_) {}));
    onRead();
  }

  /// Sends text and/or a photo; true when it was sent (errors are rethrown).
  Future<bool> send({required String body, UploadFile? photo, String? replyTo}) async {
    if ((body.isEmpty && photo == null) || sending) return false;
    sending = true;
    _changed();
    try {
      final sent = await repo.send(chatId, body: body.isEmpty ? null : body, photos: [?photo], replyTo: replyTo);
      messages = [sent, ...messages];
      return true;
    } finally {
      sending = false;
      _changed();
    }
  }

  /// Mutes my copy of the chat for [duration]; null unmutes.
  Future<void> mute(MuteDuration? duration) async {
    chat = await repo.mute(chatId, duration);
    _changed();
  }

  /// Sets my reaction, or clears it when it is the same emoji.
  Future<void> react(ChatMessage message, String emoji, String meId) async {
    final updated = await repo.react(chatId, message.id, message.reactionOf(meId) == emoji ? null : emoji);
    messages = [for (final m in messages) m.id == updated.id ? updated : m];
    _changed();
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    super.dispose();
  }
}
