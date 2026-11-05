import 'package:flutter/material.dart';

import '../../constants/ui_text.dart';

part 'password_fields_new_password_fields.dart';
part 'password_fields_password_checklist.dart';
part 'password_fields_password_field.dart';
part 'password_fields_password_field_state.dart';

/// The server's password rules (the breached-password check runs on the server only).
abstract final class PasswordRules {
  static const minLength = 10;

  static List<({String label, bool ok})> check(String value) => [
    (label: '$minLength+ characters', ok: value.length >= minLength),
    (label: UiText.upperAndLowerCase, ok: RegExp('[a-z]').hasMatch(value) && RegExp('[A-Z]').hasMatch(value)),
    (label: UiText.aNumber, ok: RegExp(r'\d').hasMatch(value)),
    (label: UiText.aSymbol, ok: RegExp('[^A-Za-z0-9]').hasMatch(value)),
  ];

  static bool valid(String value) => check(value).every((c) => c.ok);
}
