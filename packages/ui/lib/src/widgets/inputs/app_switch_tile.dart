import 'package:flutter/material.dart';

import 'app_switch.dart';

/// A list row with the app's [AppSwitch] at its end; tapping anywhere on the row toggles it.
class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.secondary,
    this.contentPadding,
  });

  final bool value;

  /// Null disables the row.
  final ValueChanged<bool>? onChanged;
  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: ListTile(
        contentPadding: contentPadding,
        leading: secondary,
        title: title,
        subtitle: subtitle,
        trailing: AppSwitch(value: value, onChanged: onChanged),
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged!(!value),
      ),
    );
  }
}
