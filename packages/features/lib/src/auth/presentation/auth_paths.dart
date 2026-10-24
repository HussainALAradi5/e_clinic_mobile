/// Routes of the shared sign-in feature (both apps).
abstract final class AuthPaths {
  static const splash = '/splash';
  static const login = '/login';
  static const twoFactor = '/login/2fa';
  static const forgotPassword = '/password/forgot';
  static const lock = '/lock';
  static const security = '/account/security';

  /// Reachable without a session.
  static const public = {login, twoFactor, forgotPassword};
}
