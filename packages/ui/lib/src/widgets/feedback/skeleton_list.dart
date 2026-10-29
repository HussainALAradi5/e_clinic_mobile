import 'package:flutter/material.dart';

/// Placeholder blocks shaped like a list of cards, gently pulsing (no spinner).
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4, this.height = 96});

  final int count;
  final double height;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Loading',
      child: FadeTransition(
        opacity: reduceMotion ? const AlwaysStoppedAnimation<double>(1) : Tween(begin: 0.45, end: 1.0).animate(_pulse),
        child: Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Container(
                height: widget.height,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
              ),
          ],
        ),
      ),
    );
  }
}
