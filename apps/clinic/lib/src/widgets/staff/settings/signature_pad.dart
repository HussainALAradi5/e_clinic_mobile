import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

part 'signature_pad_controller.dart';

/// Sign with a finger or pen: smooth dark-blue strokes on white, the shape of a signature line.
class SignaturePad extends StatelessWidget {
  const SignaturePad({super.key, required this.controller, required this.label});

  final SignaturePadController controller;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            controller._size = Size(box.maxWidth, box.maxHeight);
            return GestureDetector(
              onPanStart: (d) => controller._start(d.localPosition),
              onPanUpdate: (d) => controller._extend(d.localPosition),
              child: CustomPaint(painter: _SignaturePainter(controller), size: Size.infinite),
            );
          },
        ),
      ),
    ),
  );
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.controller) : super(repaint: controller);

  final SignaturePadController controller;

  static final _ink = Paint()
    ..color = const Color(0xFF0F2A5C)
    ..strokeWidth = 2.6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in controller._strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, _ink);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
