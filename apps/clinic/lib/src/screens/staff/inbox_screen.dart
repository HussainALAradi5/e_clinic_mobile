import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/common/common_text.dart';
import '../../constants/common/notification_link_text.dart';
import '../../constants/staff/inbox_text.dart';
import '../../controllers/staff/support_providers.dart';
import '../../widgets/common/notification_kind_icon.dart';
import '../../widgets/common/notification_message_sheet.dart';

part 'inbox_screen_filters.dart';
part 'inbox_screen_notification_card.dart';

/// `/inbox` — my notifications, unread first: All / Unread / Read, what they are about and a search, filtered and
/// paged on the server (more load as you scroll). Unread ones are on a blue background. Tapping one marks it read
/// and shows the message with a button to its record; the card's own "Open …" button goes straight there.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  static const _pageSize = 20;

  var _read = InboxRead.all;
  String? _topic;
  var _search = '';
  var _version = 0;
  int? _total;

  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  Object get _reloadKey => (_read, _topic, _search, _version);

  Future<Paged<AppNotification>> _load(int page) async {
    final result = await _repo.inbox(
      ListQuery(
        page: page,
        perPage: _pageSize,
        search: _search,
        filter: _topic == null ? null : Where.eq('relatedType', _topic!),
      ),
      read: _read,
    );
    if (mounted && page == 1) setState(() => _total = result.meta.total);
    return result;
  }

  /// Marks it read, then shows the message (with a button to its page); [direct] goes straight to the page.
  Future<void> _open(AppNotification item, void Function(AppNotification) replace, {bool direct = false}) async {
    if (item.unread) {
      try {
        replace(await _repo.markRead(item.id));
        ref.invalidate(staffUnreadProvider);
      } on ApiException {
        // Opening still works; the blue clears next time.
      }
    }
    final path = StaffPaths.forNotification(item.relatedType, item.relatedId);
    if (!mounted) return;
    final go = direct || await NotificationMessageSheet.show(context, item, hasLink: path != null);
    if (go && path != null && mounted) unawaited(context.push(path));
  }

  Future<void> _markAllRead() async {
    await _repo.markAllRead();
    ref.invalidate(staffUnreadProvider);
    if (!mounted) return;
    setState(() => _version++);
    AppSnack.success(context, InboxText.allRead);
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(staffUnreadProvider).value ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(InboxText.notifications),
        actions: [
          if (unread > 0)
            AppButton(label: CommonText.markAllRead, variant: ButtonVariant.text, onPressed: _markAllRead),
          const SizedBox(width: 8),
        ],
      ),
      // The filters live above the list (not in its header), so the search field keeps its text and focus
      // while the list reloads.
      body: Column(
        children: [
          _InboxFilters(
            read: _read,
            topic: _topic,
            unread: unread,
            total: _total,
            onSearch: (v) => setState(() => _search = v),
            onRead: (v) => setState(() => _read = v),
            onTopic: (v) => setState(() => _topic = v),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() => _version++),
              child: InfiniteList<AppNotification>(
                reloadKey: _reloadKey,
                load: _load,
                empty: EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: InboxText.emptyTitle(filtered: _read != InboxRead.all || _topic != null || _search.isNotEmpty),
                  message: InboxText.emptyHint,
                ),
                itemBuilder: (context, item, replace) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _NotificationCard(
                    item: item,
                    onTap: () => _open(item, replace),
                    onGo: () => _open(item, replace, direct: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
