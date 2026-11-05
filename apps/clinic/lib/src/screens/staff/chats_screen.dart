import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/common/common_text.dart';
import '../../constants/staff/chat_text.dart';
import '../../controllers/staff/chat_actions.dart';
import '../../controllers/staff/chat_providers.dart';
import '../../widgets/staff/chat/chat_avatar.dart';
import '../../widgets/staff/chat/presence_switch.dart';

part 'chats_screen_chat_filters.dart';
part 'chats_screen_chat_list.dart';
part 'chats_screen_chat_menu.dart';
part 'chats_screen_chat_menu_choice.dart';
part 'chats_screen_chat_row.dart';
part 'chats_screen_chat_toolbar.dart';
part 'chats_screen_contact_picker.dart';
part 'chats_screen_contact_picker_state.dart';

/// `/chat` — my chats, newest first: search, chips All · Unread · Groups · One-to-one, paging, unread badges, my
/// Online / Offline switch; long-press for Open / Mark as read / Mute / Exit group / Delete chat (mine only).
/// "New chat" starts a one-to-one chat. Refreshes every 20 s, and at once when a colleague goes Online / Offline.
class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  var _filter = ChatFilter.all;
  var _search = '';
  var _version = 0;
  int? _total;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(chatListPollEvery, (_) {
      if (mounted) setState(() => _version++);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<Paged<Conversation>> _load(int page) async {
    final result = await ref
        .read(chatRepositoryProvider)
        .conversations(page: page, search: _search.trim().isEmpty ? null : _search.trim(), filter: _filter);
    if (mounted && page == 1) setState(() => _total = result.meta.total);
    return result;
  }

  Future<void> _open(Conversation chat) async {
    await context.push(StaffPaths.chat(chat.id));
    if (mounted) {
      setState(() => _version++);
      ref.invalidate(chatUnreadProvider);
    }
  }

  Future<void> _menu(Conversation chat) async {
    final choice = await _ChatMenu.show(context, chat);
    if (!mounted || choice == null) return;
    final repo = ref.read(chatRepositoryProvider);
    switch (choice) {
      case _ChatMenuChoice.open:
        await _open(chat);
      case _ChatMenuChoice.read:
        await repo.markRead(chat.id);
        ref.invalidate(chatUnreadProvider);
        setState(() => _version++);
      case _ChatMenuChoice.mute:
        final duration = await ChatActions.pickMute(context);
        if (duration != null && mounted && await ChatActions.mute(context, ref, chat, duration) && mounted) {
          setState(() => _version++);
        }
      case _ChatMenuChoice.unmute:
        if (await ChatActions.mute(context, ref, chat, null) && mounted) setState(() => _version++);
      case _ChatMenuChoice.leave:
        if (await ChatActions.leave(context, ref, chat) && mounted) setState(() => _version++);
      case _ChatMenuChoice.delete:
        if (await ChatActions.delete(context, ref, chat) && mounted) setState(() => _version++);
    }
  }

  Future<void> _newChat() async {
    final contact = await _ContactPicker.show(context);
    if (contact == null || !mounted) return;
    try {
      final chat = await ref.read(chatRepositoryProvider).startDirect(contact.id);
      if (mounted) await _open(chat);
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(presenceChangesProvider, (_, _) => setState(() => _version++));
    final canStart = ref.watch(accessProvider).can('chat.create');
    return Scaffold(
      appBar: AppBar(title: const Text(ChatText.title), actions: const [PresenceSwitch(), SizedBox(width: 8)]),
      floatingActionButton: canStart
          ? FloatingActionButton.extended(
              onPressed: _newChat,
              icon: const Icon(Icons.edit_square),
              label: const Text(ChatText.newChat),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChatToolbar(
            filter: _filter,
            total: _total,
            onSearch: (v) => setState(() => _search = v),
            onFilter: (v) => setState(() => _filter = v),
          ),
          Expanded(
            child: _ChatList(
              reloadKey: (_filter, _search, _version),
              load: _load,
              meId: ref.watch(currentUserProvider)?.id ?? '',
              onRefresh: () => setState(() => _version++),
              onOpen: _open,
              onMenu: _menu,
            ),
          ),
        ],
      ),
    );
  }
}
