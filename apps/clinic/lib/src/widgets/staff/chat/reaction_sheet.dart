import 'package:flutter/material.dart';

/// Emoji in colour: the default text font draws plain glyphs for some (❤️, ⚠️) on Android.
const emojiStyle = TextStyle(
  fontFamily: 'Noto Color Emoji',
  fontFamilyFallback: ['Apple Color Emoji', 'Segoe UI Emoji'],
);

/// What the long-press sheet of a message answered.
sealed class MessageAction {
  const MessageAction();
}

class ReactAction extends MessageAction {
  const ReactAction(this.emoji);

  final String emoji;
}

class ReplyAction extends MessageAction {
  const ReplyAction();
}

class CopyAction extends MessageAction {
  const CopyAction();
}

/// Long-press a message: the quick reactions (mine ringed — picking it again takes it back), "+" for the full set,
/// Reply and Copy. Dismiss by dragging down or tapping outside: nothing has to be picked.
Future<MessageAction?> showMessageActions(
  BuildContext context, {
  required List<String> quick,
  required List<String> all,
  required String? mine,
  required bool canCopy,
}) => showModalBottomSheet<MessageAction>(
  context: context,
  showDragHandle: true,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (context) => _ActionsSheet(quick: quick, all: all, mine: mine, canCopy: canCopy),
);

class _ActionsSheet extends StatefulWidget {
  const _ActionsSheet({required this.quick, required this.all, required this.mine, required this.canCopy});

  final List<String> quick;
  final List<String> all;
  final String? mine;
  final bool canCopy;

  @override
  State<_ActionsSheet> createState() => _ActionsSheetState();
}

class _ActionsSheetState extends State<_ActionsSheet> {
  var _more = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extra = widget.all.where((e) => !widget.quick.contains(e)).toList();
    Widget emoji(String e) {
      final chosen = e == widget.mine;
      return Semantics(
        button: true,
        selected: chosen,
        label: chosen ? 'Remove reaction $e' : 'React $e',
        child: InkResponse(
          onTap: () => Navigator.of(context).pop(ReactAction(e)),
          radius: 26,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: chosen
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(alpha: 0.16),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.6), width: 2),
                  )
                : null,
            child: Text(e, style: emojiStyle.copyWith(fontSize: 28)),
          ),
        ),
      );
    }

    // Clear of the system navigation bar.
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 16 + MediaQuery.viewPaddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              for (final e in widget.quick) emoji(e),
              if (extra.isNotEmpty)
                IconButton.filledTonal(
                  tooltip: _more ? 'Fewer emojis' : 'More emojis',
                  onPressed: () => setState(() => _more = !_more),
                  icon: Icon(_more ? Icons.expand_less_rounded : Icons.add_rounded),
                ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: _more
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: SingleChildScrollView(
                        child: Wrap(alignment: WrapAlignment.center, children: [for (final e in extra) emoji(e)]),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.reply_rounded),
            title: const Text('Reply'),
            onTap: () => Navigator.of(context).pop(const ReplyAction()),
          ),
          if (widget.canCopy)
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy text'),
              onTap: () => Navigator.of(context).pop(const CopyAction()),
            ),
        ],
      ),
    );
  }
}
