part of 'auth_routing.dart';

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
