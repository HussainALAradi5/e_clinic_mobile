part of 'ticket_detail_screen.dart';

/// The reply box and Send; cleared once [onSend] is done.
class _ReplyBox extends StatefulWidget {
  const _ReplyBox({required this.onSend});

  final Future<void> Function(String body) onSend;

  @override
  State<_ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<_ReplyBox> {
  final _reply = TextEditingController();

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _reply.text.trim();
    if (body.isEmpty) return;
    await widget.onSend(body);
    _reply.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _reply,
          minLines: 2,
          maxLines: 5,
          maxLength: 5000,
          decoration: const InputDecoration(labelText: TicketText.writeAReply, border: OutlineInputBorder()),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(label: CommonText.send, icon: Icons.send_rounded, onPressed: _send),
        ),
      ],
    );
  }
}
