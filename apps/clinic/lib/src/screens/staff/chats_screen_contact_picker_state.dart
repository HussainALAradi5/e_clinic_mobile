part of 'chats_screen.dart';

/// Search colleagues on the server (name, phone, email or staff no.) as you type, one page at a time with "Show more".
class _ContactPickerState extends ConsumerState<_ContactPicker> {
  final _found = <ChatContact>[];
  var _search = '';
  var _page = 0;
  var _hasMore = false;
  var _total = 0;
  var _loading = false;
  Object? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();
    _debounce = Timer(ChatText.debounce, () {
      _search = value.trim();
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    final search = _search;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(chatRepositoryProvider)
          .contacts(search: search.isEmpty ? null : search, page: reset ? 1 : _page + 1, perPage: ChatText.pageSize);
      if (!mounted || search != _search) return; // a newer search started meanwhile
      setState(() {
        if (reset) _found.clear();
        _found.addAll(page.items);
        _page = page.meta.currentPage ?? 1;
        _hasMore = page.hasMore;
        _total = page.meta.total ?? _found.length;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.75,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ChatText.newChat, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SearchField(hint: ChatText.search, onChanged: _changed),
            ],
          ),
        ),
        Expanded(child: _results(context)),
      ],
    ),
  );

  Widget _results(BuildContext context) {
    if (_error != null && _found.isEmpty) return ErrorState(error: _error!, onRetry: () => _load(reset: true));
    if (_found.isEmpty) {
      return _loading
          ? const Center(child: CircularProgressIndicator())
          : const EmptyState(icon: Icons.person_search_outlined, title: ChatText.nobody);
    }
    return ListView.builder(
      itemCount: _found.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _found.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: AppButton(
              label: '${ChatText.more} · ${ChatText.count(_found.length, _total)}',
              icon: Icons.expand_more_rounded,
              variant: ButtonVariant.text,
              expand: true,
              onPressed: _loading ? null : () => _load(reset: false),
            ),
          );
        }
        final c = _found[i];
        return ListTile(
          leading: ChatAvatar(name: c.fullName, seed: c.id, url: c.avatarUrl, size: 40),
          title: Text(c.fullName),
          subtitle: c.userType == null ? null : Text(c.userType!.replaceAll('_', ' ')),
          onTap: () => Navigator.pop(context, c),
        );
      },
    );
  }
}
