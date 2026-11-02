part of 'user.dart';

@freezed
abstract class TwoFactorState with _$TwoFactorState {
  const factory TwoFactorState({
    @Default(false) bool enabled,

    /// One of the user's roles makes two-step sign-in mandatory.
    @JsonKey(name: 'required') @Default(false) bool mandatory,
  }) = _TwoFactorState;

  factory TwoFactorState.fromJson(Map<String, dynamic> json) => _$TwoFactorStateFromJson(json);
}
