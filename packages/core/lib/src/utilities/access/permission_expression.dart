/// Same grammar as the server's PermissionExpression: `&` (and), `|` (or), `!` (not), parentheses;
/// `authenticated` = signed in; `x.read_all` implies `x.read_own`; unknown names are false (fail closed).
/// Hiding a button is a convenience — the server checks every request.
class Access {
  const Access(this.permissions, {required this.signedIn});

  static const guest = Access({}, signedIn: false);
  static const authenticated = 'authenticated';

  final Set<String> permissions;
  final bool signedIn;

  bool can(String expression) {
    if (!signedIn) return false;
    final parser = _Parser(expression.toLowerCase(), _allows);
    final result = parser.parseOr();
    if (!parser.done) {
      throw FormatException('Unexpected token in permission expression', expression);
    }
    return result;
  }

  bool _allows(String name) {
    if (name == authenticated || permissions.contains(name)) return true;
    final dot = name.indexOf('.');
    return dot > 0 &&
        name.substring(dot + 1) == 'read_own' &&
        permissions.contains('${name.substring(0, dot)}.read_all');
  }
}

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
