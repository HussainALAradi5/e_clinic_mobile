import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/staff/chat_providers.dart';
import '../../widgets/common/attach_photo_button.dart';
import '../../widgets/staff/chat/chat_avatar.dart';
import '../../widgets/staff/chat/message_bubble.dart';
import '../../widgets/staff/chat/reaction_sheet.dart';

part 'chat_screen_composer.dart';
part 'chat_screen_day_separator.dart';

/// `/chat/:id` — one chat: messages newest at the bottom (older ones load as you scroll up), day separators,
/// long-press for reactions / Reply / Copy, swipe right to reply, a quote above the box while replying, photos.
/// New messages arrive every few seconds while the chat is open; opening it marks it read.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scroll = ScrollController();
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _keys = <String, GlobalKey>{};

  Conversation? _chat;
  Object? _error;
  var _messages = <ChatMessage>[]; // newest first (the list is reversed)
  var _hasMore = false;
  var _loadingOlder = false;
  var _sending = false;
  ChatMessage? _replyTo;
  XFile? _photo;
  String? _flash;
  Timer? _poll;

  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  String get _me => ref.read(currentUserProvider)?.id ?? '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeOlder);
    _text.addListener(() => setState(() {}));
    unawaited(_load());
    _poll = Timer.periodic(chatPollEvery, (_) => _fresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _scroll.dispose();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([_repo.conversation(widget.id), _repo.messages(widget.id)]);
      final page = results[1] as Paged<ChatMessage>;
      if (!mounted) return;
      setState(() {
        _chat = results[0] as Conversation;
        _messages = page.items;
        _hasMore = page.hasMore;
        _error = null;
      });
      _markRead();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// New messages (and reaction changes) since the newest page.
  Future<void> _fresh() async {
    if (_chat == null || _chat!.deletedAt != null) return;
    try {
      final page = await _repo.messages(widget.id);
      if (!mounted) return;
      final latest = {for (final m in page.items) m.id: m};
      final known = _messages.map((m) => m.id).toSet();
      final added = page.items.where((m) => !known.contains(m.id)).length;
      setState(() => _messages = [...page.items, ..._messages.where((m) => !latest.containsKey(m.id))]);
      if (added > 0) _markRead();
    } catch (_) {
      // Quiet: the next tick tries again.
    }
  }

  void _maybeOlder() {
    if (!_hasMore || _loadingOlder || _messages.isEmpty) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 300) return;
    _loadingOlder = true;
    _repo
        .messages(widget.id, before: _messages.last.id)
        .then((page) {
          if (!mounted) return;
          setState(() {
            _messages = [..._messages, ...page.items];
            _hasMore = page.hasMore;
          });
        })
        .whenComplete(() => _loadingOlder = false);
  }

  void _markRead() {
    if (_chat?.deletedAt != null) return;
    unawaited(_repo.markRead(widget.id).catchError((_) {}));
    ref.invalidate(chatUnreadProvider);
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if ((body.isEmpty && _photo == null) || _sending) return;
    setState(() => _sending = true);
    try {
      final sent = await _repo.send(
        widget.id,
        body: body.isEmpty ? null : body,
        photos: [if (_photo case final p?) (path: p.path, name: p.name)],
        replyTo: _replyTo?.id,
      );
      if (!mounted) return;
      _text.clear();
      setState(() {
        _messages = [sent, ..._messages];
        _replyTo = null;
        _photo = null;
      });
      unawaited(_scroll.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut));
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _react(ChatMessage message, String emoji) async {
    try {
      final updated = await _repo.react(widget.id, message.id, message.reactionOf(_me) == emoji ? null : emoji);
      if (mounted) setState(() => _messages = [for (final m in _messages) m.id == updated.id ? updated : m]);
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
    }
  }

  void _reply(ChatMessage message) {
    setState(() => _replyTo = message);
    _focus.requestFocus();
  }

  Future<void> _menu(ChatMessage message) async {
    final reactions = ref.read(chatReactionsProvider).value;
    final action = await showMessageActions(
      context,
      quick: reactions?.quick ?? fallbackReactions,
      all: reactions?.all ?? fallbackReactions,
      mine: message.reactionOf(_me),
      canCopy: (message.body ?? '').isNotEmpty,
    );
    if (!mounted) return;
    switch (action) {
      case ReactAction(:final emoji):
        await _react(message, emoji);
      case ReplyAction():
        _reply(message);
      case CopyAction():
        await Clipboard.setData(ClipboardData(text: message.body ?? ''));
        if (mounted) AppSnack.success(context, 'Copied.');
      case null:
        break;
    }
  }

  /// A quote was tapped: scroll its original into view and flash it (when loaded).
  Future<void> _jump(String id) async {
    final target = _keys[id]?.currentContext;
    if (target == null) {
      AppSnack.info(context, 'That message is further back — scroll up to load it.');
      return;
    }
    await Scrollable.ensureVisible(target, alignment: 0.4, duration: const Duration(milliseconds: 300));
    setState(() => _flash = id);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _flash = null);
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final theme = Theme.of(context);
    ref.watch(chatReactionsProvider);
    if (chat == null) {
      return Scaffold(
        appBar: AppBar(),
        body: _error == null
            ? const Center(child: CircularProgressIndicator())
            : ErrorState(error: _error!, onRetry: _load),
      );
    }
    final others = chat.members.where((m) => !m.isMe).map((m) => m.fullName.split(' ').first);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ChatAvatar(
              name: chat.title,
              seed: chat.partnerId ?? chat.id,
              url: chat.avatarUrl,
              group: chat.isGroup,
              size: 38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.title, overflow: TextOverflow.ellipsis),
                  if (chat.isGroup)
                    Text(
                      '${chat.members.length} members · ${others.join(', ')}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const EmptyState(icon: Icons.waving_hand_outlined, title: 'No messages yet', message: 'Say hello.')
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    itemCount: _messages.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final m = _messages[i];
                      final older = i + 1 < _messages.length ? _messages[i + 1] : null;
                      final day = ClinicClock.isoDate(ClinicClock.local(m.createdAt));
                      final newDay = older == null || ClinicClock.isoDate(ClinicClock.local(older.createdAt)) != day;
                      final first = newDay || older.sender.id != m.sender.id;
                      return Column(
                        key: _keys.putIfAbsent(m.id, GlobalKey.new),
                        children: [
                          if (newDay) _DaySeparator(label: ClinicClock.relativeDay(day)),
                          MessageBubble(
                            message: m,
                            meId: _me,
                            group: chat.isGroup,
                            first: first,
                            highlight: _flash == m.id,
                            onMenu: () => _menu(m),
                            onReply: () => _reply(m),
                            onReact: (e) => _react(m, e),
                            onQuote: _jump,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (chat.deletedAt != null)
            InfoNote(icon: Icons.delete_sweep_outlined, text: 'Deleted by ${chat.deletedBy ?? 'someone'} — read-only.')
          else
            _Composer(
              text: _text,
              focus: _focus,
              sending: _sending,
              replyTo: _replyTo,
              meId: _me,
              photo: _photo,
              onCancelReply: () => setState(() => _replyTo = null),
              onPhoto: () async {
                final picked = await pickPhoto(context);
                if (picked != null && mounted) setState(() => _photo = picked);
              },
              onRemovePhoto: () => setState(() => _photo = null),
              onSend: _send,
            ),
        ],
      ),
    );
  }
}
