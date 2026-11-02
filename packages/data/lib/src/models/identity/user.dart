import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

part 'user_session.dart';
part 'user_two_factor_setup.dart';
part 'user_two_factor_state.dart';

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
