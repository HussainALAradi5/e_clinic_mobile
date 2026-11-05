import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../constants/common/common_text.dart';
import '../../constants/common/notification_link_text.dart';
import '../../constants/portal/notification_text.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/common/notification_kind_icon.dart';
import '../../widgets/common/notification_message_sheet.dart';

/// `/notifications` — the in-app inbox: reminders, confirmations, results ready. Tapping one shows the message
/// with a button to its page; the card's "Open …" button goes straight there.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const _pageSize = 25;
  var _version = 0;

  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  /// Marks it read, then shows the message (with a button to its page); [direct] goes straight to the page.
  Future<void> _open(AppNotification item, void Function(AppNotification) replace, {bool direct = false}) async {
    if (item.unread) {
      try {
        replace(await _repo.markRead(item.id));
        ref.invalidate(unreadCountProvider);
      } on ApiException {
        // Reading still works offline; the dot clears next time.
      }
    }
    final path = PortalPaths.forRelated(item.relatedType);
    if (!mounted) return;
    final go = direct || await NotificationMessageSheet.show(context, item, hasLink: path != null);
    if (go && path != null && mounted) {
      if (path == PortalPaths.treatments || path == PortalPaths.prescriptions) {
        unawaited(context.push(path));
      } else {
        context.go(path);
      }
    }
  }

  Future<void> _markAllRead() async {
    await _repo.markAllRead();
    ref.invalidate(unreadCountProvider);
    if (!mounted) return;
    setState(() => _version++);
    AppSnack.success(context, NotificationText.allRead);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(CommonText.messages),
      actions: [
        if ((ref.watch(unreadCountProvider).value ?? 0) > 0)
          AppButton(label: CommonText.markAllRead, variant: ButtonVariant.text, onPressed: _markAllRead),
        const SizedBox(width: 8),
      ],
    ),
    body: InfiniteList<AppNotification>(
      reloadKey: _version,
      load: (page) => _repo.inbox(ListQuery(page: page, perPage: _pageSize)),
      empty: const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: NotificationText.noMessages,
        message: NotificationText.noMessagesHint,
      ),
      itemBuilder: (context, item, replace) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return Card(
          color: item.unread ? scheme.secondaryContainer : null,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _open(item, replace),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationKindIcon(kind: item.kind, unread: item.unread),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.subject != null)
                          Text(
                            item.subject!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: item.unread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        Text(item.body, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              ClinicClock.ago(item.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const Spacer(),
                            if (PortalPaths.forRelated(item.relatedType) != null)
                              TextButton(
                                onPressed: () => _open(item, replace, direct: true),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                child: Text(NotificationLinkText.openFor(item.relatedType)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
