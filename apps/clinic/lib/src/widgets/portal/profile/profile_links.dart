import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/portal_paths.dart';
import '../../../constants/common/common_text.dart';

/// "More" on the profile: treatments, prescriptions, sick leaves, messages, password & security.
class ProfileLinks extends StatelessWidget {
  const ProfileLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return LinkGroup(
      links: [
        LinkTile(
          icon: Icons.self_improvement_rounded,
          label: CommonText.myTreatments,
          onTap: () => context.push(PortalPaths.treatments),
        ),
        LinkTile(
          icon: Icons.medication_outlined,
          label: CommonText.myPrescriptions,
          onTap: () => context.push(PortalPaths.prescriptions),
        ),
        LinkTile(
          icon: Icons.sick_outlined,
          label: CommonText.mySickLeaves,
          onTap: () => context.push(PortalPaths.sickLeaves),
        ),
        LinkTile(
          icon: Icons.notifications_none_rounded,
          label: CommonText.messages,
          onTap: () => context.push(PortalPaths.messages),
        ),
        LinkTile(
          icon: Icons.shield_outlined,
          label: CommonText.passwordSecurity,
          onTap: () => context.push(AuthPaths.security),
        ),
      ],
    );
  }
}
