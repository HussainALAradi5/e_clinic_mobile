part of 'list_query.dart';

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
