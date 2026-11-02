part of 'list_query.dart';

/// A filter tree in the server grammar (API conventions §5): `filter[field][op]=value`,
/// `filter[and][0][field][op]=value`, `filter[not][field][op]=value`. Field names are camelCase here, snake_case on the wire.
sealed class FilterNode {
  const FilterNode();

  void _write(Map<String, String> out, String prefix);
}
