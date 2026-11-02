import 'dart:convert';
import 'dart:io';

import 'package:e_clinic_data/data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real `/chat` answers from the local API (signed links shortened): the models read every field the screens use.
void main() {
  final fixture = jsonDecode(File('test/fixtures/chat.json').readAsStringSync()) as Map<String, dynamic>;

  test('a chat in the list reads with its members and last message', () {
    final chat = Conversation.fromJson(fixture['conversation'] as Map<String, dynamic>);
    expect(chat.title, isNotEmpty);
    expect(chat.members, isNotEmpty);
    expect(chat.members.where((m) => m.isMe), hasLength(1));
    expect(chat.lastMessage, isNotNull);
    expect(chat.deletedAt, isNull);
    expect(chat.canDelete, chat.isGroup ? chat.iLead : isTrue);
  });

  test('messages read with their quote, files and reactions', () {
    final messages = [
      for (final m in fixture['messages'] as List<dynamic>) ChatMessage.fromJson(m as Map<String, dynamic>),
    ];
    final reply = messages.first;
    expect(reply.replyTo, isNotNull);
    expect(reply.replyTo!.senderName, isNotEmpty);
    expect(reply.replyTo!.excerpt, isNotEmpty);
    expect(messages.last.attachments, isNotEmpty);
    for (final m in messages) {
      for (final r in m.reactions) {
        expect(r.count, r.userIds.length);
      }
    }
  });

  test('contacts and the reaction sets read', () {
    final contacts = [
      for (final c in fixture['contacts'] as List<dynamic>) ChatContact.fromJson(c as Map<String, dynamic>),
    ];
    expect(contacts.first.fullName, isNotEmpty);
    final settings = fixture['settings'] as Map<String, dynamic>;
    expect(
      (settings['all_reactions'] as List<dynamic>).length,
      greaterThan((settings['reactions'] as List<dynamic>).length),
    );
  });
}
