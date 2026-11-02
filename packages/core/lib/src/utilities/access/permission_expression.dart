part 'permission_expression_parser.dart';

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
