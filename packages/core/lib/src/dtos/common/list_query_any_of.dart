part of 'list_query.dart';

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
