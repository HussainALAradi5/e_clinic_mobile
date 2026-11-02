part of 'support_ticket.dart';

/// A reply on a ticket; `author.isSupport` marks the support team.
@freezed
abstract class TicketComment with _$TicketComment {
  const factory TicketComment({
    required String id,
    required String body,
    required TicketAuthor author,
    @Default(false) bool isMe,
    required DateTime createdAt,
  }) = _TicketComment;

  factory TicketComment.fromJson(Map<String, dynamic> json) => _$TicketCommentFromJson(json);
}
