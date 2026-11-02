import 'package:flutter/material.dart';

/// Late is amber, overtime blue — the same colours as the web and the badges (StaffRequestType).
abstract final class RequestTone {
  static Color of(BuildContext context, {required bool late}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return late
        ? (dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
        : (dark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB));
  }

  static Color soft(BuildContext context, {required bool late}) => of(context, late: late).withValues(alpha: 0.14);

  static IconData icon({required bool late}) => late ? Icons.running_with_errors_rounded : Icons.more_time_rounded;
}
