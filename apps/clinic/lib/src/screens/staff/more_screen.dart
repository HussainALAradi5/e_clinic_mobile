import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/staff/month_summary_text.dart';
import '../../constants/staff/signature_text.dart';
import '../../controllers/staff/chat_providers.dart';
import '../../controllers/staff/support_providers.dart';

/// `/more` — who is signed in, the work pages the role may open, password & security, sign out.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final user = session?.user;
    final access = ref.watch(accessProvider);
    final unread = ref.watch(staffUnreadProvider).value ?? 0;
    final chatUnread = access.can('chat.read_own | chat.read_all') ? ref.watch(chatUnreadProvider).value ?? 0 : 0;
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (user != null)
            ProfileHeader(name: user.fullName, lines: [session?.roles.map(humanise).join(', '), user.email]),
          const SizedBox(height: 16),
          if (StaffPage.visible(access) case final pages when pages.isNotEmpty) ...[
            LinkGroup(
              links: [
                for (final page in pages)
                  LinkTile(
                    icon: page.icon,
                    label: page.label,
                    subtitle: switch (page) {
                      StaffPage.inbox when unread > 0 => '$unread unread',
                      StaffPage.chat when chatUnread > 0 =>
                        '$chatUnread unread ${chatUnread == 1 ? 'message' : 'messages'}',
                      _ => null,
                    },
                    onTap: () => context.push(page.path),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const ThemeModeTile(),
          const PhoneNotificationsTile(),
          const SizedBox(height: 16),
          LinkGroup(
            links: [
              LinkTile(
                icon: Icons.shield_outlined,
                label: 'Password & security',
                onTap: () => context.push(AuthPaths.security),
              ),
              if (access.can('reports.read_all'))
                LinkTile(
                  icon: Icons.insights_rounded,
                  label: MonthSummaryText.title,
                  subtitle: MonthSummaryText.link,
                  onTap: () => context.push(StaffPaths.monthSummary),
                ),
              LinkTile(
                icon: Icons.draw_outlined,
                label: SignatureText.title,
                subtitle: SignatureText.linkSubtitle,
                onTap: () => context.push(StaffPaths.signature),
              ),
            ],
          ),
          const InfoNote(
            icon: Icons.computer_rounded,
            text:
                'Billing, stock, HR and reports are on the clinic website. '
                'This app keeps nothing medical on the phone.',
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            variant: ButtonVariant.outlined,
            expand: true,
            confirm: const ConfirmConfig(title: 'Sign out of e-Clinic?', confirmLabel: 'Sign out'),
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
