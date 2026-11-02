part of 'list_query.dart';

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
