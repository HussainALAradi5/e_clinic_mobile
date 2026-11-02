part of 'infinite_list.dart';

class _InfiniteListState<T> extends State<InfiniteList<T>> {
  final _items = <T>[];
  var _page = 0;
  var _hasMore = true;
  var _loading = false;
  var _firstLoad = true;
  Object? _error;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void didUpdateWidget(InfiniteList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadKey != widget.reloadKey) {
      setState(() {
        _items.clear();
        _firstLoad = true;
      });
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    _page = 0;
    _hasMore = true;
    _loading = false;
    await _next(reset: true);
  }

  Future<void> _next({bool reset = false}) async {
    if (_loading || !_hasMore) return;
    final generation = reset ? ++_generation : _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.load(_page + 1);
      if (!mounted || generation != _generation) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.items);
        _page++;
        _hasMore = page.hasMore && page.items.isNotEmpty;
        _loading = false;
        _firstLoad = false;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
        _firstLoad = false;
      });
    }
  }

  void _replace(T old, T updated) {
    final index = _items.indexOf(old);
    if (index >= 0) setState(() => _items[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final header = widget.header;
    final Widget body;
    if (_firstLoad) {
      body = ListView(physics: const AlwaysScrollableScrollPhysics(), children: [?header, const SkeletonList()]);
    } else if (_items.isEmpty) {
      body = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ?header,
          if (_error != null) ErrorState(error: _error!, onRetry: _refresh) else widget.empty,
        ],
      );
    } else {
      final leading = header == null ? 0 : 1;
      body = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 400) unawaited(_next());
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: leading + _items.length + 1,
          itemBuilder: (context, index) {
            if (index < leading) return header;
            final i = index - leading;
            if (i == _items.length) return _footer();
            final item = _items[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: widget.itemBuilder(context, item, (updated) => _replace(item, updated)),
            );
          },
        ),
      );
    }
    return RefreshIndicator(onRefresh: _refresh, child: body);
  }

  Widget _footer() {
    if (_error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: _next,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Could not load more — try again'),
        ),
      );
    }
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.4))),
      );
    }
    return const SizedBox.shrink();
  }
}
