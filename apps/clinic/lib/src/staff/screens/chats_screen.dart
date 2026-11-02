import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/chat_providers.dart';
import '../staff_paths.dart';
import '../widgets/chat/chat_avatar.dart';

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

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat, required this.meId, required this.onTap, required this.onLongPress});

  final Conversation chat;
  final String meId;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String get _preview {
    final m = chat.lastMessage;
    if (m == null) return chat.isGroup ? 'Group created' : 'Say hello';
    final who = m.sender.id == meId ? 'You: ' : (chat.isGroup ? '${m.sender.fullName.split(' ').first}: ' : '');
    final what = switch (m.kind) {
      'voice' => '🎤 Voice note',
      'media' when (m.body ?? '').isEmpty => '📎 ${m.attachments.firstOrNull?.isImage ?? false ? 'Photo' : 'File'}',
      _ => m.body ?? '',
    };
    return '$who$what';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = chat.unreadCount > 0;
    final when = chat.activity;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ChatAvatar(name: chat.title, seed: chat.partnerId ?? chat.id, url: chat.avatarUrl, group: chat.isGroup),
      title: Row(
        children: [
          Flexible(
            child: Text(
              chat.title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: unread ? FontWeight.w700 : null),
            ),
          ),
          if (chat.isGroup && chat.iLead) ...[
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700, semanticLabel: 'You lead this group'),
          ],
        ],
      ),
      subtitle: Text(_preview, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (when != null)
            Text(
              ClinicClock.ago(when),
              style: theme.textTheme.labelSmall?.copyWith(color: unread ? const Color(0xFF15803D) : null),
            ),
          const SizedBox(height: 4),
          if (unread)
            Badge(
              label: Text(chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}'),
              backgroundColor: const Color(0xFF15803D),
            ),
        ],
      ),
    );
  }
}

/// Pick a colleague (server search as you type).
class _ContactPicker extends ConsumerStatefulWidget {
  const _ContactPicker();

  @override
  ConsumerState<_ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends ConsumerState<_ContactPicker> {
  var _search = '';
  late Future<List<ChatContact>> _contacts = ref.read(chatRepositoryProvider).contacts();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String value) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(
          () => _contacts = ref.read(chatRepositoryProvider).contacts(search: _search.trim().isEmpty ? null : _search),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.75,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New chat', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SearchField(hint: 'Search a colleague', onChanged: _changed),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ChatContact>>(
            future: _contacts,
            builder: (context, snap) {
              if (snap.hasError) return ErrorState(error: snap.error!);
              final list = snap.data;
              if (list == null) return const Center(child: CircularProgressIndicator());
              if (list.isEmpty) return const EmptyState(icon: Icons.person_search_outlined, title: 'Nobody found');
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  return ListTile(
                    leading: ChatAvatar(name: c.fullName, seed: c.id, url: c.avatarUrl, size: 40),
                    title: Text(c.fullName),
                    subtitle: c.userType == null ? null : Text(c.userType!.replaceAll('_', ' ')),
                    onTap: () => Navigator.pop(context, c),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
