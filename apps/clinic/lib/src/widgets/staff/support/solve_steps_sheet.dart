import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// What the person who solved it wrote: the solution in words, and the steps when the fix was step by step.
typedef TicketSolution = ({String resolution, List<String> steps});

/// Mark a ticket solved: the solution in words (required) and, optionally, the steps that fixed it, in order (add or
/// remove). Returns the solution, or null when the sheet is closed.
Future<TicketSolution?> showSolveStepsSheet(BuildContext context, {required String requester}) =>
    showModalBottomSheet<TicketSolution>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SolveStepsSheet(requester: requester),
    );

class _SolveStepsSheet extends StatefulWidget {
  const _SolveStepsSheet({required this.requester});

  final String requester;

  @override
  State<_SolveStepsSheet> createState() => _SolveStepsSheetState();
}

class _SolveStepsSheetState extends State<_SolveStepsSheet> {
  static const _max = 20;
  final _solution = TextEditingController();
  final _fields = [TextEditingController()];

  List<String> get _filled => [
    for (final f in _fields)
      if (f.text.trim().isNotEmpty) f.text.trim(),
  ];

  @override
  void dispose() {
    _solution.dispose();
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  void _add() {
    if (_fields.length < _max) setState(() => _fields.add(TextEditingController()));
  }

  void _remove(int i) => setState(() => _fields.removeAt(i).dispose());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = _filled.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark this ticket solved', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.requester} sees what you write here and is asked to confirm it works.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _solution,
              minLines: 3,
              maxLines: 6,
              maxLength: 1000,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Solution *',
                hintText: 'What was wrong and what you did',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text('Steps (optional — for a step-by-step fix)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            for (final (i, field) in _fields.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text('${i + 1}', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: field,
                        maxLength: 500,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Step ${i + 1}',
                          hintText: i == 0 ? 'e.g. Cleaned the print head' : 'Next step',
                          border: const OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove step',
                      onPressed: _fields.length == 1 ? null : () => _remove(i),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: _fields.length >= _max ? null : _add,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add a step'),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: count == 0 ? 'Mark solved' : 'Mark solved ($count ${count == 1 ? 'step' : 'steps'})',
              icon: Icons.task_alt_rounded,
              expand: true,
              onPressed: _solution.text.trim().isEmpty
                  ? null
                  : () async =>
                        Navigator.pop<TicketSolution>(context, (resolution: _solution.text.trim(), steps: _filled)),
            ),
          ],
        ),
      ),
    );
  }
}
