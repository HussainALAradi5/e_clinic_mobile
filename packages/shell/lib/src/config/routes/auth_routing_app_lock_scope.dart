part of 'auth_routing.dart';

/// Tells the app lock when the app goes to the background and comes back.
class AppLockScope extends ConsumerStatefulWidget {
  const AppLockScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockScope> createState() => _AppLockScopeState();
}
