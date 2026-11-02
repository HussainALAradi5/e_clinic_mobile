part of 'permission_expression.dart';

class _Parser {
  _Parser(String expression, this._allows)
    : _tokens = RegExp(r'[a-z0-9_.]+|[&|!()]').allMatches(expression).map((m) => m[0]!).toList();

  final List<String> _tokens;
  final bool Function(String name) _allows;
  var _position = 0;

  bool get done => _position >= _tokens.length;

  bool _accept(String token) {
    if (!done && _tokens[_position] == token) {
      _position++;
      return true;
    }
    return false;
  }

  bool parseOr() {
    var value = _parseAnd();
    while (_accept('|')) {
      final next = _parseAnd();
      value = value || next;
    }
    return value;
  }

  bool _parseAnd() {
    var value = _parseUnary();
    while (_accept('&')) {
      final next = _parseUnary();
      value = value && next;
    }
    return value;
  }

  bool _parseUnary() {
    if (_accept('!')) return !_parseUnary();
    if (_accept('(')) {
      final value = parseOr();
      if (!_accept(')')) throw const FormatException('Missing closing parenthesis in permission expression');
      return value;
    }
    if (done) throw const FormatException('Expected a permission name');
    return _allows(_tokens[_position++]);
  }
}
