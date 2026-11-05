part of 'inbox_screen.dart';

/// Above the inbox list: the search, All / Unread / Read, what the messages are about, and how many there are.
class _InboxFilters extends StatelessWidget {
  const _InboxFilters({
    required this.read,
    required this.topic,
    required this.unread,
    required this.total,
    required this.onSearch,
    required this.onRead,
    required this.onTopic,
  });

  final InboxRead read;
  final String? topic;
  final int unread;
  final int? total;
  final ValueChanged<String> onSearch;
  final ValueChanged<InboxRead> onRead;
  final ValueChanged<String?> onTopic;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SearchField(hint: InboxText.searchNotifications, onChanged: onSearch),
      ),
      ChipBar<InboxRead>(
        options: [
          (value: InboxRead.all, label: CommonText.all, count: null),
          (value: InboxRead.unread, label: CommonText.unread, count: unread > 0 ? unread : null),
          (value: InboxRead.read, label: InboxText.read, count: null),
        ],
        selected: read,
        onSelected: onRead,
      ),
      const SizedBox(height: 8),
      ChipBar<String?>(
        options: [
          (value: null, label: InboxText.everything, count: null),
          for (final t in inboxTopics) (value: t.value, label: t.label, count: null),
        ],
        selected: topic,
        onSelected: onTopic,
      ),
      if (total != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(InboxText.count(total!), style: Theme.of(context).textTheme.labelMedium),
        ),
    ],
  );
}
