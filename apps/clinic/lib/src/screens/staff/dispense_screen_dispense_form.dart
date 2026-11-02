part of 'dispense_screen.dart';

class _DispenseForm extends ConsumerStatefulWidget {
  const _DispenseForm({required this.prescription});

  final Prescription prescription;

  @override
  ConsumerState<_DispenseForm> createState() => _DispenseFormState();
}
