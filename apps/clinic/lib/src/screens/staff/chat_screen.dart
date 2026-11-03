import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/staff/chat_providers.dart';
import '../../controllers/staff/chat_thread_controller.dart';
import '../../widgets/common/attach_photo_button.dart';
import '../../widgets/staff/chat/chat_avatar.dart';
import '../../widgets/staff/chat/message_bubble.dart';
import '../../widgets/staff/chat/reaction_sheet.dart';

part 'chat_screen_composer.dart';
part 'chat_screen_day_separator.dart';
part 'chat_screen_message_list.dart';
part 'chat_screen_reply_preview.dart';
part 'chat_screen_title.dart';

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
  late final _thread = ChatThreadController(
    repo: ref.read(chatRepositoryProvider),
    chatId: widget.id,
    onRead: () => ref.invalidate(chatUnreadProvider),
  );

  ChatMessage? _replyTo;

  String get _me => ref.read(currentUserProvider)?.id ?? '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeOlder);
    _thread.start();
  }

  @override
  void dispose() {
    _thread.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _maybeOlder() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) _thread.loadOlder();
  }

  Future<bool> _send(String body, XFile? photo) async {
    try {
      final sent = await _thread.send(
        body: body,
        photo: photo == null ? null : (path: photo.path, name: photo.name),
        replyTo: _replyTo?.id,
      );
      if (!sent || !mounted) return sent;
      setState(() => _replyTo = null);
      await _scroll.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      return true;
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
      return false;
    }
  }

  Future<void> _react(ChatMessage message, String emoji) async {
    try {
      await _thread.react(message, emoji, _me);
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
    }
  }

  void _reply(ChatMessage message) => setState(() => _replyTo = message);

  @override
  Widget build(BuildContext context) {
    final reactions = ref.watch(chatReactionsProvider).value;
    return ListenableBuilder(
      listenable: _thread,
      builder: (context, _) {
        final chat = _thread.chat;
        if (chat == null) {
          return Scaffold(
            appBar: AppBar(),
            body: _thread.error == null
                ? const Center(child: CircularProgressIndicator())
                : ErrorState(error: _thread.error!, onRetry: _thread.load),
          );
        }
        return Scaffold(
          appBar: AppBar(titleSpacing: 0, title: _ChatTitle(chat: chat)),
          body: Column(
            children: [
              Expanded(
                child: _MessageList(
                  chat: chat,
                  messages: _thread.messages,
                  hasMore: _thread.hasMore,
                  scroll: _scroll,
                  meId: _me,
                  reactions: reactions,
                  onReply: _reply,
                  onReact: _react,
                ),
              ),
              if (chat.deletedAt != null)
                InfoNote(
                  icon: Icons.delete_sweep_outlined,
                  text: 'Deleted by ${chat.deletedBy ?? 'someone'} — read-only.',
                )
              else
                _Composer(
                  sending: _thread.sending,
                  replyTo: _replyTo,
                  meId: _me,
                  onCancelReply: () => setState(() => _replyTo = null),
                  onSend: _send,
                ),
            ],
          ),
        );
      },
    );
  }
}
