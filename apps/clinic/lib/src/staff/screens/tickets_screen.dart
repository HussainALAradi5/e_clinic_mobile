import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../staff_paths.dart';

/// Status chips of the ticket list (GenericStatus on the server).
enum _StatusFilter {
  all('All', []),
  open('Open', [GenericStatus.pending, GenericStatus.inProgress]),
  pending('Pending', [GenericStatus.pending]),
  inProgress('In progress', [GenericStatus.inProgress]),
  completed('Solved', [GenericStatus.completed]),
  cancelled('Cancelled', [GenericStatus.cancelled]);

  const _StatusFilter(this.label, this.statuses);
  final String label;
  final List<GenericStatus> statuses;
}

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
      appBar: AppBar(title: Text(desk ? 'Support desk' : 'My support tickets')),
      floatingActionButton: access.can('tickets.create')
          ? FloatingActionButton.extended(
              onPressed: _new,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New ticket'),
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
                child: SearchField(hint: 'Search subject or ticket', onChanged: (v) => setState(() => _search = v)),
              ),
              ChipBar<_StatusFilter>(
                options: [for (final s in _StatusFilter.values) (value: s, label: s.label, count: null)],
                selected: _status,
                onSelected: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 8),
              ChipBar<String?>(
                options: [
                  (value: null, label: 'Any priority', count: null),
                  for (final p in _priorities) (value: p, label: catalog.label('TreatmentPriority', p), count: null),
                ],
                selected: _priority,
                onSelected: (v) => setState(() => _priority = v),
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
                  title: 'No tickets here',
                  message: desk ? 'Nothing matches these filters.' : 'Report a problem with “New ticket”.',
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

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.showRequester});

  final SupportTicket ticket;
  final bool showRequester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(StaffPaths.ticket(ticket.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(ticket.code, style: muted?.copyWith(fontFamily: 'monospace')),
                  const Spacer(),
                  Text(ClinicClock.ago(ticket.createdAt), style: muted),
                ],
              ),
              const SizedBox(height: 4),
              Text(ticket.subject, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  StatusChip(enumName: 'GenericStatus', value: ticket.status),
                  StatusChip(enumName: 'TreatmentPriority', value: ticket.priority),
                  StatusChip(enumName: 'TicketCategory', value: ticket.category),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (showRequester && ticket.requester != null) 'By ${ticket.requester!.fullName}',
                        ticket.assignee == null ? 'Not taken yet' : 'Taken by ${ticket.assignee!.fullName}',
                      ].join(' · '),
                      style: muted,
                    ),
                  ),
                  if ((ticket.commentsCount ?? 0) > 0) ...[
                    Icon(Icons.chat_bubble_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${ticket.commentsCount}', style: muted),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
