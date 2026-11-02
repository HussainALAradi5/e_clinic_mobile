import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

/// What the performer writes when an order is done.
typedef OrderResult = ({String report, bool abnormal});

/// Bottom sheet for the result of an order: the report and whether it is abnormal (which alerts the doctor).
class CompleteOrderSheet extends StatefulWidget {
  const CompleteOrderSheet({super.key, required this.order});

  final ClinicalOrder order;

  @override
  State<CompleteOrderSheet> createState() => _CompleteOrderSheetState();
}

class _CompleteOrderSheetState extends State<CompleteOrderSheet> {
  final _report = TextEditingController();
  var _abnormal = false;

  @override
  void dispose() {
    _report.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final order = widget.order;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Result of ${order.code}', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            [order.description, if (order.patient != null) order.patient!.fullName].join(' · '),
            style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _report,
            autofocus: true,
            minLines: 4,
            maxLines: 10,
            maxLength: 10000,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Report', alignLabelWithHint: true),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _abnormal,
            onChanged: (v) => setState(() => _abnormal = v),
            title: const Text('Abnormal finding'),
            subtitle: const Text('The ordering doctor is alerted.'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _report.text.trim().isEmpty
                ? null
                : () => Navigator.pop<OrderResult>(context, (report: _report.text.trim(), abnormal: _abnormal)),
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Save result'),
          ),
        ],
      ),
    );
  }
}
