import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/staff/chat_text.dart';
import '../../controllers/staff/chat_actions.dart';
import '../../controllers/staff/chat_providers.dart';
import '../../controllers/staff/chat_thread_controller.dart';
import '../../widgets/common/attach_photo_button.dart';
import '../../widgets/staff/chat/chat_avatar.dart';
import '../../widgets/staff/chat/chat_info_sheet.dart';
import '../../widgets/staff/chat/chat_menu.dart';
import '../../widgets/staff/chat/message_bubble.dart';
import '../../widgets/staff/chat/reaction_sheet.dart';

part 'chat_screen_app_bar.dart';
part 'chat_screen_composer.dart';
part 'chat_screen_day_separator.dart';
part 'chat_screen_footer.dart';
part 'chat_screen_loading.dart';
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

  /// Bumped on every reply pick, so the picked message swings again.
  int _pick = 0;

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
    var sent = false;
    await _guard(() async {
      final file = photo == null ? null : (path: photo.path, name: photo.name);
      sent = await _thread.send(body: body, photo: file, replyTo: _replyTo?.id);
      if (!sent || !mounted) return;
      setState(() => _replyTo = null);
      await _scroll.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    });
    return sent;
  }

  /// Runs [action]; a failure shows as an error message, success as [done] when given.
  Future<void> _guard(Future<void> Function() action, {String? done}) async {
    try {
      await action();
      if (mounted && done != null) AppSnack.success(context, done);
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
    }
  }

  Future<void> _react(ChatMessage message, String emoji) => _guard(() => _thread.react(message, emoji, _me));

  void _reply(ChatMessage message) => setState(() {
    _replyTo = message;
    _pick++;
  });

  Future<void> _leave(Conversation chat) async {
    if (await ChatActions.leave(context, ref, chat)) await _thread.load();
  }

  Future<void> _delete(Conversation chat) async {
    if (await ChatActions.delete(context, ref, chat) && mounted) Navigator.of(context).pop();
  }

  Future<void> _mute(MuteDuration? duration) =>
      _guard(() => _thread.mute(duration), done: duration == null ? ChatText.unmutedDone : ChatText.mutedDone);

  void _info(Conversation chat) => ChatInfoSheet.show(context, chat);

  @override
  Widget build(BuildContext context) {
    final reactions = ref.watch(chatReactionsProvider).value;
    return ListenableBuilder(
      listenable: _thread,
      builder: (context, _) {
        final chat = _thread.chat;
        if (chat == null) return _ChatLoading(error: _thread.error, onRetry: _thread.load);
        return Scaffold(
          appBar: _ChatAppBar(
            chat: chat,
            onInfo: () => _info(chat),
            onMute: _mute,
            onLeave: () => _leave(chat),
            onDelete: () => _delete(chat),
          ),
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
                  pickedId: _replyTo?.id,
                  pick: _pick,
                  onReact: _react,
                ),
              ),
              _ChatFooter(
                chat: chat,
                sending: _thread.sending,
                replyTo: _replyTo,
                meId: _me,
                onCancelReply: () => setState(() => _replyTo = null),
                onSend: _send,
                onDelete: () => _delete(chat),
              ),
            ],
          ),
        );
      },
    );
  }
}
