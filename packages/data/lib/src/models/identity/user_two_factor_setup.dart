part of 'user.dart';

/// POST /auth/two-factor/enable.
@freezed
abstract class TwoFactorSetup with _$TwoFactorSetup {
  const factory TwoFactorSetup({required String qrCodeSvg, required String otpauthUrl}) = _TwoFactorSetup;

  factory TwoFactorSetup.fromJson(Map<String, dynamic> json) => _$TwoFactorSetupFromJson(json);
}
