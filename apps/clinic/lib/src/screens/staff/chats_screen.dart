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
import '../../controllers/staff/chat_providers.dart';
import '../../widgets/staff/chat/chat_avatar.dart';

part 'chats_screen_chat_row.dart';
part 'chats_screen_contact_picker.dart';
part 'chats_screen_contact_picker_state.dart';

/// `/chat` — my chats, newest activity first: search (every word of a name), chips All · Unread · Groups ·
/// One-to-one (on the server), paging as you scroll, unread badges. Long-press a chat for Open / Mark as read /
/// Delete chat (a soft delete). "New chat" starts a one-to-one chat with a colleague. Refreshes every 20 s.
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
    unawaited(HapticFeedback.mediumImpact());
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(chat.title, style: Theme.of(context).textTheme.titleMedium)),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Open'),
              onTap: () => Navigator.pop(context, 'open'),
            ),
            if (chat.unreadCount > 0)
              ListTile(
                leading: const Icon(Icons.done_all_rounded),
                title: const Text('Mark as read'),
                onTap: () => Navigator.pop(context, 'read'),
              ),
            if (chat.canDelete)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                title: Text('Delete chat', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    final repo = ref.read(chatRepositoryProvider);
    switch (choice) {
      case 'open':
        await _open(chat);
      case 'read':
        await repo.markRead(chat.id);
        ref.invalidate(chatUnreadProvider);
        setState(() => _version++);
      case 'delete':
        final ok = await showConfirmSheet(
          context,
          ConfirmConfig(
            title: 'Delete "${chat.title}"?',
            message: chat.isGroup
                ? 'The group disappears for every member. Nothing is erased — an admin can restore it.'
                : 'The chat disappears for both of you. Nothing is erased — an admin can restore it.',
            confirmLabel: 'Delete chat',
            danger: true,
          ),
        );
        if (!ok || !mounted) return;
        try {
          await repo.delete(chat.id);
          if (mounted) {
            AppSnack.success(context, 'Chat deleted.');
            setState(() => _version++);
          }
        } catch (e) {
          if (mounted) AppSnack.error(context, e);
        }
    }
  }

  Future<void> _newChat() async {
    final contact = await showModalBottomSheet<ChatContact>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const _ContactPicker(),
    );
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
    final canStart = ref.watch(accessProvider).can('chat.create');
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      floatingActionButton: canStart
          ? FloatingActionButton.extended(
              onPressed: _newChat,
              icon: const Icon(Icons.edit_square),
              label: const Text('New chat'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchField(hint: 'Search chats or people', onChanged: (v) => setState(() => _search = v)),
          ),
          ChipBar<ChatFilter>(
            options: const [
              (value: ChatFilter.all, label: 'All', count: null),
              (value: ChatFilter.unread, label: 'Unread', count: null),
              (value: ChatFilter.groups, label: 'Groups', count: null),
              (value: ChatFilter.direct, label: 'One-to-one', count: null),
            ],
            selected: _filter,
            onSelected: (v) => setState(() => _filter = v),
          ),
          if (_total != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('$_total ${_total == 1 ? 'chat' : 'chats'}', style: Theme.of(context).textTheme.labelMedium),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() => _version++),
              child: InfiniteList<Conversation>(
                reloadKey: (_filter, _search, _version),
                load: _load,
                empty: const EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No chats here',
                  message: 'Try another filter, or start a new chat.',
                ),
                itemBuilder: (context, chat, _) => _ChatRow(
                  chat: chat,
                  meId: ref.watch(currentUserProvider)?.id ?? '',
                  onTap: () => _open(chat),
                  onLongPress: () => _menu(chat),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
