import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/staff_providers.dart';
import '../staff_paths.dart';

/// Bottom navigation with the tabs the user's rights allow (each keeps its own scroll and state).
/// Patient accounts are turned away: they use the patient app.
class StaffShell extends ConsumerWidget {
  const StaffShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(currentUserProvider)?.isPatient ?? false) return const _PatientAccount();

    final tabs = StaffTab.visible(ref.watch(accessProvider));
    final current = tabs.indexOf(StaffTab.values[shell.currentIndex]);
    final waiting = ref.watch(approvalsCountProvider).value ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: current < 0 ? 0 : current,
        onDestinationSelected: (index) {
          final branch = StaffTab.values.indexOf(tabs[index]);
          // Tapping the current tab again returns to its start.
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: tab == StaffTab.approvals && waiting > 0
                  ? Badge(label: Text('$waiting'), child: Icon(tab.icon))
                  : Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _PatientAccount extends ConsumerWidget {
  const _PatientAccount();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Center(
        child: EmptyState(
          icon: Icons.badge_outlined,
          title: 'This app is for clinic staff',
          message: 'Patients sign in to the e-Clinic patient app to see their visits, results and invoices.',
          action: AppButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            variant: ButtonVariant.outlined,
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ),
      ),
    ),
  );
}
