import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// A coloured left edge on a visit card: coming, today, past or missed.
class TimingEdge extends StatelessWidget {
  const TimingEdge({super.key, required this.timing, required this.child});

  final VisitTiming timing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = StatusEdge.of(StatusColors.tone('VisitTiming', wireValue(timing)), Theme.of(context).brightness);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: child,
    );
  }
}
