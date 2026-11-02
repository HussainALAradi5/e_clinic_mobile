part of 'password_fields.dart';

/// Password input with a show / hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.password],
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String? value)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String> autofillHints;
  final String? errorText;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}
