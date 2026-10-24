import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Friendly empty screen with an optional next step.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// What went wrong and a way to try again (offline gets its own wording).
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;
    final offline = api?.isOffline ?? false;
    return EmptyState(
      icon: offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
      title: offline ? 'You are offline' : 'Could not load this',
      message: api?.message ?? 'Something went wrong. Please try again.',
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
    );
  }
}

/// Placeholder blocks shaped like a list of cards, gently pulsing (no spinner).
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4, this.height = 96});

  final int count;
  final double height;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Loading',
      child: FadeTransition(
        opacity: reduceMotion ? const AlwaysStoppedAnimation<double>(1) : Tween(begin: 0.45, end: 1.0).animate(_pulse),
        child: Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Container(
                height: widget.height,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Loading → skeleton, error → retry, data → [data].
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.data, this.onRetry, this.loading});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) => value.when(
    data: data,
    loading: () => loading ?? const Padding(padding: EdgeInsets.only(top: 16), child: SkeletonList()),
    error: (error, _) => Center(
      child: ErrorState(error: error, onRetry: onRetry),
    ),
  );
}
