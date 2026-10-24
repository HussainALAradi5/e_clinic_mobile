import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class TwoFactorState with _$TwoFactorState {
  const factory TwoFactorState({
    @Default(false) bool enabled,

    /// One of the user's roles makes two-step sign-in mandatory.
    @JsonKey(name: 'required') @Default(false) bool mandatory,
  }) = _TwoFactorState;

  factory TwoFactorState.fromJson(Map<String, dynamic> json) => _$TwoFactorStateFromJson(json);
}

/// Mirror of UserResource — the login account with its person's name.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String code,
    required String firstName,
    required String lastName,
    required String fullName,
    String? email,
    String? phone,
    required String userType,
    @Default(TwoFactorState()) TwoFactorState twoFactor,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isPatient => userType == 'patient';
}

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

/// POST /auth/two-factor/enable.
@freezed
abstract class TwoFactorSetup with _$TwoFactorSetup {
  const factory TwoFactorSetup({required String qrCodeSvg, required String otpauthUrl}) = _TwoFactorSetup;

  factory TwoFactorSetup.fromJson(Map<String, dynamic> json) => _$TwoFactorSetupFromJson(json);
}
