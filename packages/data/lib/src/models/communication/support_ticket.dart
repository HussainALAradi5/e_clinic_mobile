import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/shared/generic_status.dart';
import '../clinic/clinical_order.dart' show Attachment;
import '../shared/refs.dart';

part 'support_ticket.freezed.dart';
part 'support_ticket.g.dart';

/// Mirror of TicketResource. Status is the shared GenericStatus (completed = solved); priority the shared
/// TreatmentPriority (`medium`, `high`, `urgent`); category a TicketCategory value. Badges come from the enum names.
@freezed
abstract class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String id,
    required String code,
    required String subject,
    required String description,
    required String category,
    required String priority,
    @JsonKey(unknownEnumValue: GenericStatus.unknown) required GenericStatus status,
    @Default(<GenericStatus>[]) List<GenericStatus> allowedTransitions,
    PersonRef? requester,
    PersonRef? assignee,
    PersonRef? resolver,
    DateTime? resolvedAt,
    String? resolution,

    /// The steps that solved it, in order.
    @Default(<String>[]) List<String> resolutionSteps,

    /// The requester's answer once solved: `awaiting`, `confirmed` or `declined` (TicketConfirmation).
    String? confirmation,
    DateTime? confirmedAt,

    /// Screenshots, photos and PDFs on the ticket.
    @Default(<Attachment>[]) List<Attachment> attachments,
    int? commentsCount,
    @Default(<TicketComment>[]) List<TicketComment> comments,
    required int version,
    required DateTime createdAt,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, dynamic> json) => _$SupportTicketFromJson(json);

  const SupportTicket._();

  /// Solved and waiting for the requester to confirm or decline.
  bool get awaitsConfirmation => status == GenericStatus.completed && confirmation == 'awaiting';
}

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

@freezed
abstract class TicketAuthor with _$TicketAuthor {
  const factory TicketAuthor({required String id, required String fullName, @Default(false) bool isSupport}) =
      _TicketAuthor;

  factory TicketAuthor.fromJson(Map<String, dynamic> json) => _$TicketAuthorFromJson(json);
}
