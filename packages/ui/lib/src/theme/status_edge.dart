import 'package:flutter/material.dart';

import 'status_colors.dart';

/// The strong colour of a tone: a card's coloured left edge, a legend dot (chips use [StatusColors.of]).
abstract final class StatusEdge {
  static Color of(StatusTone tone, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    Color strong(MaterialColor c) => dark ? c.shade400 : c.shade500;
    return switch (tone) {
      StatusTone.grey => dark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
      StatusTone.blue => strong(Colors.blue),
      StatusTone.teal => strong(Colors.teal),
      StatusTone.green => strong(Colors.green),
      StatusTone.amber => strong(Colors.amber),
      StatusTone.red || StatusTone.redOutline => strong(Colors.red),
      StatusTone.orange => strong(Colors.orange),
      StatusTone.cyan => strong(Colors.cyan),
      StatusTone.indigo => strong(Colors.indigo),
      StatusTone.purple => strong(Colors.purple),
      StatusTone.pink => strong(Colors.pink),
    };
  }
}
