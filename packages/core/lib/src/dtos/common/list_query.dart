import '../../utilities/text.dart';

part 'list_query_all_of.dart';
part 'list_query_any_of.dart';
part 'list_query_filter_node.dart';
part 'list_query_none_of.dart';
part 'list_query_where.dart';

/// Mirror of the server ListQuery: paging, sort (`-field` = descending), search and a filter tree.
class ListQuery {
  const ListQuery({this.page, this.perPage, this.sort = const [], this.search, this.filter});

  /// The server caps a page at 100 rows.
  static const maxPerPage = 100;

  final int? page;
  final int? perPage;
  final List<String> sort;
  final String? search;
  final FilterNode? filter;

  ListQuery copyWith({int? page}) =>
      ListQuery(page: page ?? this.page, perPage: perPage, sort: sort, search: search, filter: filter);

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
    return out;
  }
}
