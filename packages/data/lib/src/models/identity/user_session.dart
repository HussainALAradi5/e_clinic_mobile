part of 'user.dart';

/// POST /auth/login, POST /auth/two-factor/challenge (with a token) and GET /auth/me (without).
@freezed
abstract class Session with _$Session {
  const factory Session({
    required User user,
    @Default([]) List<String> roles,
    @Default([]) List<String> permissions,
    String? token,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
