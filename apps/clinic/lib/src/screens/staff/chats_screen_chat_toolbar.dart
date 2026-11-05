part of 'chats_screen.dart';

/// Above the list: the search box, the filter chips and how many chats match.
class _ChatToolbar extends StatelessWidget {
  const _ChatToolbar({required this.filter, required this.total, required this.onSearch, required this.onFilter});

  final ChatFilter filter;
  final int? total;
  final ValueChanged<String> onSearch;
  final ValueChanged<ChatFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchField(hint: ChatText.searchChats, onChanged: onSearch),
        ),
        _ChatFilters(selected: filter, onSelected: onFilter),
        if (total case final n?)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('$n ${n == 1 ? 'chat' : 'chats'}', style: Theme.of(context).textTheme.labelMedium),
          ),
      ],
    );
  }
}
