part of 'clinical_order.dart';

/// A short-lived signed link to a file (GET /attachments/{id}/download).
@freezed
abstract class SignedLink with _$SignedLink {
  const factory SignedLink({required String url, String? expiresAt}) = _SignedLink;

  factory SignedLink.fromJson(Map<String, dynamic> json) => _$SignedLinkFromJson(json);
}
