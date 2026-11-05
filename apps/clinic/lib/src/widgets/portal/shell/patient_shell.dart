import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/portal/shell_text.dart';

/// Bottom navigation: Home · Visits · Results · Invoices · Profile (each tab keeps its own scroll and state).
class PatientShell extends StatelessWidget {
  const PatientShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (icon: Icons.home_outlined, selected: Icons.home_rounded, label: ShellText.home),
    (icon: Icons.event_outlined, selected: Icons.event_rounded, label: ShellText.visits),
    (icon: Icons.science_outlined, selected: Icons.science_rounded, label: CommonText.results),
    (icon: Icons.receipt_long_outlined, selected: Icons.receipt_long_rounded, label: CommonText.invoices),
    (icon: Icons.person_outline_rounded, selected: Icons.person_rounded, label: ShellText.profile),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      // Tapping the current tab again returns to its start.
      onDestinationSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
      destinations: [
        for (final tab in _tabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: PopIn(child: Icon(tab.selected)),
            label: tab.label,
          ),
      ],
    ),
  );
}
