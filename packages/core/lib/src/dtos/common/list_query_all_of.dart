part of 'list_query.dart';

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
