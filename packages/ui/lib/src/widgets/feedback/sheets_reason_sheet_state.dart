part of 'sheets.dart';

class _ReasonSheetState extends State<_ReasonSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _reason,
    builder: (context, value, _) => _SheetBody(
      config: widget.config,
      onConfirm: value.text.trim().isEmpty ? null : () => Navigator.of(context).pop(value.text.trim()),
      child: TextField(
        controller: _reason,
        autofocus: true,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: widget.label),
      ),
    ),
  );
}
