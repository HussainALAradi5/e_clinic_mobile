import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

import '../feedback/error_state.dart';
import '../feedback/skeleton_list.dart';

part 'infinite_list_infinite_list_state.dart';

/// Infinite scroll with pull-to-refresh: loads page 1, then the next page shortly before the end.
/// Change [reloadKey] (e.g. a tab or filter) to start again from page 1.
class InfiniteList<T> extends StatefulWidget {
  const InfiniteList({
    super.key,
    required this.load,
    required this.itemBuilder,
    required this.empty,
    this.header,
    this.reloadKey,
  });

  final Future<Paged<T>> Function(int page) load;

  /// `replace` swaps the row for an updated record (e.g. after cancelling it).
  final Widget Function(BuildContext context, T item, void Function(T updated) replace) itemBuilder;
  final Widget empty;
  final Widget? header;
  final Object? reloadKey;

  @override
  State<InfiniteList<T>> createState() => _InfiniteListState<T>();
}
