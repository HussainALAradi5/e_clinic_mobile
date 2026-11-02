import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth/session_controller.dart';
import '../../widgets/auth/auth_scaffold.dart';

/// `/splash` — while the stored session is checked; offers a retry when the server cannot be reached.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF052A27) : BrandColors.pine,
      body: SafeArea(
        child: Center(
          child: session.hasError
              ? Card(
                  margin: const EdgeInsets.all(24),
                  child: ErrorState(error: session.error!, onRetry: () => ref.invalidate(sessionProvider)),
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandMark(),
                    SizedBox(height: 32),
                    SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
