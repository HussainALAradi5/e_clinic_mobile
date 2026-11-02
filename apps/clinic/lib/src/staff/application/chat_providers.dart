import 'package:e_clinic_data/data.dart';
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
