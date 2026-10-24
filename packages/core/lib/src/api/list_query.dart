import '../utils/text.dart';

/// A filter tree in the server grammar (API conventions §5): `filter[field][op]=value`,
/// `filter[and][0][field][op]=value`, `filter[not][field][op]=value`. Field names are camelCase here, snake_case on the wire.
sealed class FilterNode {
  const FilterNode();

  void _write(Map<String, String> out, String prefix);
}

/// One condition: `field op value`. Lists are sent comma-separated; enums by their wire value.
final class Where extends FilterNode {
  const Where(this.field, this.op, this.value);

  const Where.eq(String field, Object value) : this(field, 'eq', value);
  const Where.oneOf(String field, List<Object> values) : this(field, 'in', values);
  const Where.noneOf(String field, List<Object> values) : this(field, 'nin', values);
  const Where.gte(String field, Object value) : this(field, 'gte', value);
  const Where.lt(String field, Object value) : this(field, 'lt', value);

  final String field;
  final String op;
  final Object value;

  @override
  void _write(Map<String, String> out, String prefix) {
    out['$prefix[${snakeCase(field)}][$op]'] = wireValue(value);
  }
}

final class AllOf extends FilterNode {
  const AllOf(this.children);
  final List<FilterNode> children;

  @override
  void _write(Map<String, String> out, String prefix) {
    for (var i = 0; i < children.length; i++) {
      children[i]._write(out, '$prefix[and][$i]');
    }
  }
}

final class AnyOf extends FilterNode {
  const AnyOf(this.children);
  final List<FilterNode> children;

  @override
  void _write(Map<String, String> out, String prefix) {
    for (var i = 0; i < children.length; i++) {
      children[i]._write(out, '$prefix[or][$i]');
    }
  }
}

final class NoneOf extends FilterNode {
  const NoneOf(this.children);
  final List<FilterNode> children;

  @override
  void _write(Map<String, String> out, String prefix) {
    for (final child in children) {
      child._write(out, '$prefix[not]');
    }
  }
}

/// Mirror of the server ListQuery: paging, sort (`-field` = descending), search and a filter tree.
class ListQuery {
  const ListQuery({
    this.page,
    this.perPage,
    this.sort = const [],
    this.search,
    this.filter,
  });

  /// The server caps a page at 100 rows.
  static const maxPerPage = 100;

  final int? page;
  final int? perPage;
  final List<String> sort;
  final String? search;
  final FilterNode? filter;

  ListQuery copyWith({int? page}) => ListQuery(
    page: page ?? this.page,
    perPage: perPage,
    sort: sort,
    search: search,
    filter: filter,
  );

  Map<String, String> toParams() {
    final out = <String, String>{};
    if (page != null) out['page'] = '$page';
    if (perPage != null) out['per_page'] = '${perPage!.clamp(1, maxPerPage)}';
    if (sort.isNotEmpty) {
      out['sort'] = sort
          .map((s) => s.startsWith('-') ? '-${snakeCase(s.substring(1))}' : snakeCase(s))
          .join(',');
    }
    final term = search?.trim();
    if (term != null && term.isNotEmpty) out['search'] = term;
    filter?._write(out, 'filter');
    return out;
  }
}
