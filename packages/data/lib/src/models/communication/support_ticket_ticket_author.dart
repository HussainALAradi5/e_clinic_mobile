part of 'support_ticket.dart';

@freezed
abstract class TicketAuthor with _$TicketAuthor {
  const factory TicketAuthor({required String id, required String fullName, @Default(false) bool isSupport}) =
      _TicketAuthor;

  factory TicketAuthor.fromJson(Map<String, dynamic> json) => _$TicketAuthorFromJson(json);
}
