part of 'chats_screen.dart';

class _ContactPickerState extends ConsumerState<_ContactPicker> {
  var _search = '';
  late Future<List<ChatContact>> _contacts = ref.read(chatRepositoryProvider).contacts();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String value) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(
          () => _contacts = ref.read(chatRepositoryProvider).contacts(search: _search.trim().isEmpty ? null : _search),
        );
      }
    });
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
              Text('New chat', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SearchField(hint: 'Search a colleague', onChanged: _changed),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ChatContact>>(
            future: _contacts,
            builder: (context, snap) {
              if (snap.hasError) return ErrorState(error: snap.error!);
              final list = snap.data;
              if (list == null) return const Center(child: CircularProgressIndicator());
              if (list.isEmpty) return const EmptyState(icon: Icons.person_search_outlined, title: 'Nobody found');
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  return ListTile(
                    leading: ChatAvatar(name: c.fullName, seed: c.id, url: c.avatarUrl, size: 40),
                    title: Text(c.fullName),
                    subtitle: c.userType == null ? null : Text(c.userType!.replaceAll('_', ' ')),
                    onTap: () => Navigator.pop(context, c),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
