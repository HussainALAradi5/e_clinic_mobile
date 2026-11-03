part of 'chats_screen.dart';

/// All · Unread · Groups · One-to-one (filtered on the server).
class _ChatFilters extends StatelessWidget {
  const _ChatFilters({required this.selected, required this.onSelected});

  final ChatFilter selected;
  final ValueChanged<ChatFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChipBar<ChatFilter>(
      options: const [
        (value: ChatFilter.all, label: 'All', count: null),
        (value: ChatFilter.unread, label: 'Unread', count: null),
        (value: ChatFilter.groups, label: 'Groups', count: null),
        (value: ChatFilter.direct, label: 'One-to-one', count: null),
      ],
      selected: selected,
      onSelected: onSelected,
    );
  }
}
