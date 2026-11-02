import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth/app_lock_controller.dart';
import '../../controllers/auth/session_controller.dart';
import '../../screens/auth/account_security_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/lock_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/two_factor_screen.dart';
import 'auth_paths.dart';

/// Routes of the sign-in feature; add them at the top level of the app router.
List<RouteBase> authRoutes() => [
  GoRoute(path: AuthPaths.splash, builder: (_, _) => const SplashScreen()),
  GoRoute(path: AuthPaths.login, builder: (_, _) => const LoginScreen()),
  GoRoute(
    path: AuthPaths.twoFactor,
    redirect: (_, state) => state.extra is TwoFactorChallenge ? null : AuthPaths.login,
    builder: (_, state) => TwoFactorScreen(challenge: state.extra! as TwoFactorChallenge),
  ),
  GoRoute(
    path: AuthPaths.forgotPassword,
    builder: (_, state) => ForgotPasswordScreen(email: state.extra as String?),
  ),
  GoRoute(path: AuthPaths.lock, builder: (_, _) => const LockScreen()),
  GoRoute(path: AuthPaths.security, builder: (_, _) => const AccountSecurityScreen()),
];

/// Where the app must go: splash while the session loads, login when signed out, the lock when locked,
/// [home] when a signed-in user lands on a sign-in page. Null = stay.
/// The splash and the lock remember the page that was asked for (`?from=`), so a reload, a link or unlocking
/// returns there instead of to [home].
String? authRedirect(Ref ref, GoRouterState state, {required String home}) {
  final session = ref.read(sessionProvider);
  final path = state.matchedLocation;
  final public = AuthPaths.public.contains(path);

  if ((session.isLoading && !session.hasValue) || session.hasError) {
    return path == AuthPaths.splash ? null : _holding(AuthPaths.splash, state);
  }
  final Session? signedIn = session.value;
  if (signedIn == null) return public ? null : AuthPaths.login;
  if (ref.read(appLockProvider).locked) return path == AuthPaths.lock ? null : _holding(AuthPaths.lock, state);
  if (path == AuthPaths.splash || path == AuthPaths.lock) return _returnTo(state) ?? home;
  if (public) return home;
  return null;
}

/// [waitingPage] with the current page to come back to (the start page needs no reminder).
String _holding(String waitingPage, GoRouterState state) {
  final from = state.uri.toString();
  return from == '/' ? waitingPage : Uri(path: waitingPage, queryParameters: {'from': from}).toString();
}

/// The remembered page, if it is an in-app page that is not part of signing in.
String? _returnTo(GoRouterState state) {
  final from = state.uri.queryParameters['from'];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) return null;
  final target = Uri.parse(from).path;
  return AuthPaths.public.contains(target) || target == AuthPaths.splash || target == AuthPaths.lock ? null : from;
}

/// Re-runs the router's redirect whenever the session or the lock changes.
class AuthRefresh extends ChangeNotifier {
  AuthRefresh(Ref ref) {
    ref
      ..listen(sessionProvider, (_, _) => notifyListeners())
      ..listen(appLockProvider, (_, _) => notifyListeners());
  }
}

/// Tells the app lock when the app goes to the background and comes back.
class AppLockScope extends ConsumerStatefulWidget {
  const AppLockScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockScope> createState() => _AppLockScopeState();
}

class _AppLockScopeState extends ConsumerState<AppLockScope> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => ref.read(appLockProvider.notifier).paused(),
      onShow: () => ref.read(appLockProvider.notifier).resumed(),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
