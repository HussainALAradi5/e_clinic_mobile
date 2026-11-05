import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating messages: success with a light haptic, errors with the request reference for support.
abstract final class AppSnack {
  /// The app's messenger (`MaterialApp.scaffoldMessengerKey`), for messages raised outside a screen.
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// A titled warning shown without a [BuildContext] (router redirects, a session ended by the server).
  static void notice(String title, String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    final scheme = Theme.of(messenger.context).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: scheme.inverseSurface,
          content: Row(
            children: [
              Icon(Icons.gpp_maybe_rounded, color: scheme.onInverseSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: message),
                    ],
                  ),
                  style: TextStyle(color: scheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _show(context, message, icon: Icons.check_circle_rounded);
  }

  static void info(BuildContext context, String message) => _show(context, message, icon: Icons.info_rounded);

  static void error(BuildContext context, Object error) {
    HapticFeedback.mediumImpact();
    final message = error is ApiException ? error.message : 'Something went wrong. Please try again.';
    final requestId = error is ApiException ? error.requestId : null;
    final reference = requestId == null ? '' : '\nRef. ${requestId.length > 8 ? requestId.substring(0, 8) : requestId}';
    _show(context, '$message$reference', icon: Icons.error_rounded, isError: true);
  }

  static void _show(BuildContext context, String message, {required IconData icon, bool isError = false}) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? scheme.errorContainer : scheme.inverseSurface,
          content: Row(
            children: [
              Icon(icon, color: isError ? scheme.onErrorContainer : scheme.onInverseSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: isError ? scheme.onErrorContainer : scheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
