import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unread chat messages over all my chats (the count on More › Chat).
final chatUnreadProvider = FutureProvider.autoDispose<int>((ref) => ref.watch(chatRepositoryProvider).unreadCount());

/// The quick reaction row and the full set behind "+" (from the server; the web's defaults until loaded).
final chatReactionsProvider = FutureProvider<({List<String> quick, List<String> all})>(
  (ref) => ref.watch(chatRepositoryProvider).reactions(),
);

const fallbackReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// How often an open chat asks for new messages, and the list for new chats (no socket on the phone yet).
const chatPollEvery = Duration(seconds: 6);
const chatListPollEvery = Duration(seconds: 20);

/// Colleagues going Online / Offline, live over Reverb while I am signed in (nothing without a Reverb address).
final presenceChangesProvider = StreamProvider.autoDispose<PresenceChange>((ref) {
  final reverb = ref.watch(appConfigProvider).reverb;
  if (reverb == null || ref.watch(currentUserProvider) == null) return const Stream.empty();
  final client = RealtimeClient(config: reverb, dio: ref.watch(dioProvider));
  ref.onDispose(client.dispose);
  return client
      .listen(RealtimeChannels.staffPresence, RealtimeChannels.presenceChanged)
      .map((data) => (userId: '${data['user_id']}', presence: '${data['presence']}', at: '${data['at']}'));
});

/// One `presence.changed` event (`at` keeps two changes of the same person apart).
typedef PresenceChange = ({String userId, String presence, String at});
