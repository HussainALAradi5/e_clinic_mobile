import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../controllers/staff/support_providers.dart';
import '../../widgets/common/notification_kind_icon.dart';

part 'inbox_screen_notification_card.dart';

/// `/inbox` — my notifications, unread first: All / Unread / Read, what they are about and a search, filtered and
/// paged on the server (more load as you scroll). Unread ones are on a blue background; tapping one marks it read
/// and opens its record (a support ticket, a booking, an order …).
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

  Future<void> _open(AppNotification item, void Function(AppNotification) replace) async {
    if (item.unread) {
      try {
        replace(await _repo.markRead(item.id));
        ref.invalidate(staffUnreadProvider);
      } on ApiException {
        // Opening still works; the blue clears next time.
      }
    }
    final path = StaffPaths.forNotification(item.relatedType, item.relatedId);
    if (path != null && mounted) unawaited(context.push(path));
  }

  Future<void> _markAllRead() async {
    await _repo.markAllRead();
    ref.invalidate(staffUnreadProvider);
    if (!mounted) return;
    setState(() => _version++);
    AppSnack.success(context, 'All notifications marked as read.');
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(staffUnreadProvider).value ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0) AppButton(label: 'Mark all read', variant: ButtonVariant.text, onPressed: _markAllRead),
          const SizedBox(width: 8),
        ],
      ),
      // The filters live above the list (not in its header), so the search field keeps its text and focus
      // while the list reloads.
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchField(hint: 'Search notifications', onChanged: (v) => setState(() => _search = v)),
              ),
              ChipBar<InboxRead>(
                options: [
                  (value: InboxRead.all, label: 'All', count: null),
                  (value: InboxRead.unread, label: 'Unread', count: unread > 0 ? unread : null),
                  (value: InboxRead.read, label: 'Read', count: null),
                ],
                selected: _read,
                onSelected: (v) => setState(() => _read = v),
              ),
              const SizedBox(height: 8),
              ChipBar<String?>(
                options: [
                  (value: null, label: 'Everything', count: null),
                  for (final t in inboxTopics) (value: t.value, label: t.label, count: null),
                ],
                selected: _topic,
                onSelected: (v) => setState(() => _topic = v),
              ),
              if (_total != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '$_total ${_total == 1 ? 'notification' : 'notifications'}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() => _version++),
              child: InfiniteList<AppNotification>(
                reloadKey: _reloadKey,
                load: _load,
                empty: EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: _read == InboxRead.all && _topic == null && _search.isEmpty
                      ? 'No notifications yet'
                      : 'Nothing matches these filters',
                  message: 'Ticket updates, bookings and other news land here.',
                ),
                itemBuilder: (context, item, replace) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _NotificationCard(item: item, onTap: () => _open(item, replace)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
