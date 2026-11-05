import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/common/common_text.dart';
import '../../constants/staff/ticket_text.dart';

part 'tickets_screen_status_filter.dart';
part 'tickets_screen_ticket_card.dart';

/// `/support/tickets` — staff see the tickets they opened, admins the whole desk; status and priority chips and a
/// search, all filtered and paged on the server (more load as you scroll).
class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  static const _pageSize = 20;
  static const _priorities = ['urgent', 'high', 'medium'];

  var _status = _StatusFilter.open;
  String? _priority;
  var _search = '';
  var _version = 0;
  int? _total;

  Future<Paged<SupportTicket>> _load(int page) async {
    final filters = <FilterNode>[
      if (_status.statuses.isNotEmpty) Where.oneOf('status', _status.statuses),
      if (_priority != null) Where.eq('priority', _priority!),
    ];
    final result = await ref
        .read(ticketRepositoryProvider)
        .list(
          ListQuery(
            page: page,
            perPage: _pageSize,
            search: _search,
            sort: const ['-createdAt'],
            filter: filters.isEmpty ? null : AllOf(filters),
          ),
        );
    if (mounted && page == 1) setState(() => _total = result.meta.total);
    return result;
  }

  Future<void> _new() async {
    final created = await context.push<SupportTicket>(StaffPaths.newTicket);
    if (created != null && mounted) {
      setState(() => _version++);
      unawaited(context.push(StaffPaths.ticket(created.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(accessProvider);
    final desk = access.can('tickets.resolve');
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return Scaffold(
      appBar: AppBar(title: Text(desk ? TicketText.supportDesk : TicketText.mySupportTickets)),
      floatingActionButton: access.can('tickets.create')
          ? FloatingActionButton.extended(
              onPressed: _new,
              icon: const Icon(Icons.add_rounded),
              label: const Text(TicketText.newTicket),
            )
          : null,
      // The filters live above the list (not in its header), so the search field keeps its text and focus
      // while the list reloads.
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchField(
                  hint: TicketText.searchSubjectOrTicket,
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              ChipBar<_StatusFilter>(
                options: [for (final s in _StatusFilter.values) (value: s, label: s.label, count: null)],
                selected: _status,
                onSelected: (v) => setState(() => _status = v),
                // A single status wears its badge colour; All / Open stay neutral.
                tone: (s) => s.statuses.length == 1
                    ? StatusColors.tone(
                        'GenericStatus',
                        wireValue(s.statuses.single),
                        order: catalog.values('GenericStatus'),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              ChipBar<String?>(
                options: [
                  (value: null, label: TicketText.anyPriority, count: null),
                  for (final p in _priorities) (value: p, label: catalog.label('TreatmentPriority', p), count: null),
                ],
                selected: _priority,
                onSelected: (v) => setState(() => _priority = v),
                tone: (p) => p == null ? null : StatusColors.tone('TreatmentPriority', p),
              ),
              if (_total != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '$_total ${_total == 1 ? 'ticket' : 'tickets'}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() => _version++),
              child: InfiniteList<SupportTicket>(
                reloadKey: (_status, _priority, _search, _version),
                load: _load,
                empty: EmptyState(
                  icon: Icons.support_agent_rounded,
                  title: TicketText.noTicketsHere,
                  message: desk ? TicketText.noMatch : TicketText.noTicketsHint,
                ),
                itemBuilder: (context, ticket, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _TicketCard(ticket: ticket, showRequester: desk),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
