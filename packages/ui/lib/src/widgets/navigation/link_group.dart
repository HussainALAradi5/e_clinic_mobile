import 'package:flutter/material.dart';

import 'link_tile.dart';

/// Links stacked in one card with dividers between them.
class LinkGroup extends StatelessWidget {
  const LinkGroup({super.key, required this.links});

  final List<LinkTile> links;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < links.length; i++) ...[if (i > 0) const Divider(height: 1, indent: 56), links[i]],
      ],
    ),
  );
}
