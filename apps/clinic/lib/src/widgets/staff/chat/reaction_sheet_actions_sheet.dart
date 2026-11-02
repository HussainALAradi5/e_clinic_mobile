part of 'reaction_sheet.dart';

class _ActionsSheet extends StatefulWidget {
  const _ActionsSheet({required this.quick, required this.all, required this.mine, required this.canCopy});

  final List<String> quick;
  final List<String> all;
  final String? mine;
  final bool canCopy;

  @override
  State<_ActionsSheet> createState() => _ActionsSheetState();
}
