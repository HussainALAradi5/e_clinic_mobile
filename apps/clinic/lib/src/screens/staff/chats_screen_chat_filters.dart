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
        (value: ChatFilter.all, label: CommonText.all, count: null),
        (value: ChatFilter.unread, label: CommonText.unread, count: null),
        (value: ChatFilter.groups, label: ChatText.groups, count: null),
        (value: ChatFilter.direct, label: ChatText.oneToOne, count: null),
      ],
      selected: selected,
      onSelected: onSelected,
    );
  }
}
