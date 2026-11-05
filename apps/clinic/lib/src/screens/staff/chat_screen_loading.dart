part of 'chat_screen.dart';

/// While the chat loads, or why it could not (with a retry).
class _ChatLoading extends StatelessWidget {
  const _ChatLoading({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error;
    return Scaffold(
      appBar: AppBar(),
      body: failure == null
          ? const Center(child: CircularProgressIndicator())
          : ErrorState(error: failure, onRetry: onRetry),
    );
  }
}
