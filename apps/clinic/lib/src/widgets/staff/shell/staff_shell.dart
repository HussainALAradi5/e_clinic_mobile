import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/staff_paths.dart';
import '../../../controllers/staff/staff_providers.dart';

/// Bottom navigation with the tabs the user's rights allow (each keeps its own scroll and state).
class StaffShell extends ConsumerWidget {
  const StaffShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              selectedIcon: PopIn(child: Icon(tab.selectedIcon)),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
