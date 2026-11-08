import 'package:flutter/material.dart';

import '../../motion/motion.dart';

/// A title that opens and closes [child] below it with a smooth height change and a turning chevron. Announces its
/// state to screen readers, stands still when the system asks for no animations, and drops [child] while closed.
class AppCollapse extends StatefulWidget {
  const AppCollapse({
    super.key,
    required this.title,
    required this.child,
    this.initiallyOpen = false,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget title;
  final Widget child;
  final bool initiallyOpen;
  final EdgeInsetsGeometry titlePadding;

  @override
  State<AppCollapse> createState() => _AppCollapseState();
}

class _AppCollapseState extends State<AppCollapse> with SingleTickerProviderStateMixin {
  static const _minTapHeight = 48.0;
  static final _halfTurn = Tween<double>(begin: 0, end: 0.5);

  late var _open = widget.initiallyOpen;
  late final _controller = AnimationController(vsync: this, value: _open ? 1 : 0);
  late final _curve = CurvedAnimation(parent: _controller, curve: Motion.ease);

  void _toggle() {
    setState(() => _open = !_open);
    _controller.duration = Motion.of(context, Motion.base);
    _open ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        button: true,
        expanded: _open,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _toggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _minTapHeight),
              child: Padding(
                padding: widget.titlePadding,
                child: Row(
                  children: [
                    Expanded(child: widget.title),
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _halfTurn.animate(_curve),
                      child: Icon(Icons.expand_more_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (_, child) => _controller.isDismissed
            ? const SizedBox.shrink()
            : SizeTransition(sizeFactor: _curve, alignment: Alignment.topCenter, child: child),
      ),
    ],
  );
}
