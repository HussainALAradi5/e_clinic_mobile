import '../../utilities/text.dart';

part 'list_query_all_of.dart';
part 'list_query_any_of.dart';
part 'list_query_filter_node.dart';
part 'list_query_none_of.dart';
part 'list_query_where.dart';

/// Mirror of the server ListQuery: paging, sort (`-field` = descending), search, a filter tree and a date range
/// (`date_field` + `date_range=from..to`, either side open).
class ListQuery {
  const ListQuery({
    this.page,
    this.perPage,
    this.sort = const [],
    this.search,
    this.filter,
    this.dateField,
    this.dateFrom,
    this.dateTo,
  });

  /// The server caps a page at 100 rows.
  static const maxPerPage = 100;

  final int? page;
  final int? perPage;
  final List<String> sort;
  final String? search;
  final FilterNode? filter;

  /// The date column [dateFrom] / [dateTo] (`YYYY-MM-DD`) apply to; the server's default when null.
  final String? dateField;
  final String? dateFrom;
  final String? dateTo;

  ListQuery copyWith({int? page}) => ListQuery(
    page: page ?? this.page,
    perPage: perPage,
    sort: sort,
    search: search,
    filter: filter,
    dateField: dateField,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );

  Map<String, String> toParams() {
    final out = <String, String>{};
    if (page != null) out['page'] = '$page';
    if (perPage != null) out['per_page'] = '${perPage!.clamp(1, maxPerPage)}';
    if (sort.isNotEmpty) {
      out['sort'] = sort.map((s) => s.startsWith('-') ? '-${snakeCase(s.substring(1))}' : snakeCase(s)).join(',');
    }
    final term = search?.trim();
    if (term != null && term.isNotEmpty) out['search'] = term;
    filter?._write(out, 'filter');
    if (dateFrom != null || dateTo != null) {
      if (dateField != null) out['date_field'] = dateField!;
      out['date_range'] = '${dateFrom ?? ''}..${dateTo ?? ''}';
    }
    return out;
  }
}
