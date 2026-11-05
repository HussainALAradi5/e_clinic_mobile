part of 'message_bubble.dart';

class _Pending extends StatelessWidget {
  const _Pending();

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Text(ChatText.checkingFile, style: TextStyle(color: Colors.white)),
  );
}
