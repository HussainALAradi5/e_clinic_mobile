import 'package:flutter/material.dart';

/// A person's photo, else their initials on a steady colour (the same person always gets the same colour);
/// a group shows the group icon.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.name, required this.seed, this.url, this.group = false, this.size = 44});

  final String name;

  /// Picks the colour (a user or chat id).
  final String seed;
  final String? url;
  final bool group;
  final double size;

  static const _colors = [
    Color(0xFF0F766E),
    Color(0xFF1D4ED8),
    Color(0xFF7C3AED),
    Color(0xFFBE185D),
    Color(0xFFB45309),
    Color(0xFF15803D),
    Color(0xFF0E7490),
    Color(0xFFC2410C),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[seed.codeUnits.fold<int>(0, (a, b) => a + b) % _colors.length];
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty && w != 'Dr.')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      foregroundImage: url == null ? null : NetworkImage(url!),
      child: group
          ? Icon(Icons.groups_rounded, color: Colors.white, size: size * 0.52)
          : Text(
              initials,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.36),
            ),
    );
  }
}
