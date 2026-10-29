import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';
import 'skeleton_list.dart';

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
