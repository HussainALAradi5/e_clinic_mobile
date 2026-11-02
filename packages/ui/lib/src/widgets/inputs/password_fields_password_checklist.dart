part of 'password_fields.dart';

/// Live checklist of the password rules under a new-password field.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, value, _) {
      final scheme = Theme.of(context).colorScheme;
      return Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final rule in PasswordRules.check(value.text))
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  rule.ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: rule.ok ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: 4),
                Text(rule.label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
        ],
      );
    },
  );
}
