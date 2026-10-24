import 'package:flutter/material.dart';

/// A card that opens in place to show more (details load when first opened).
class ExpandableCard extends StatefulWidget {
  const ExpandableCard({super.key, required this.header, required this.details, this.initiallyOpen = false});

  final Widget header;

  /// Built only while open.
  final WidgetBuilder details;
  final bool initiallyOpen;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late var _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: widget.header),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [const Divider(height: 1), widget.details(context)],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
