import 'package:e_clinic_core/core.dart';

import '../../enums/shared/generic_status.dart';
import '../../models/communication/support_ticket.dart';

/// Support tickets — staff open them and follow their own; admins (`tickets.resolve`) move and solve them.
/// The list is filtered, sorted and paged on the server.
class TicketRepository {
  const TicketRepository(this._api);

  final ApiClient _api;

  static const _path = 'support/tickets';

  Future<Paged<SupportTicket>> list(ListQuery query) => _api.list(_path, query, SupportTicket.fromJson);

  Future<SupportTicket> get(String id) => _api.get('$_path/$id', objectOf(SupportTicket.fromJson));

  Future<SupportTicket> open({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) => _api.post(
    _path,
    objectOf(SupportTicket.fromJson),
    body: {'subject': subject, 'description': description, 'category': category, 'priority': priority},
  );

  Future<TicketComment> comment(String id, String body) =>
      _api.post('$_path/$id/comments', objectOf(TicketComment.fromJson), body: {'body': body});

  /// Admins only; [resolution] is required to mark it solved (completed).
  Future<SupportTicket> setStatus(SupportTicket ticket, GenericStatus to, {String? resolution}) => _api.patch(
    '$_path/${ticket.id}/status',
    objectOf(SupportTicket.fromJson),
    body: {'status': wireValue(to), 'resolution': ?resolution, 'version': ticket.version},
  );
}
