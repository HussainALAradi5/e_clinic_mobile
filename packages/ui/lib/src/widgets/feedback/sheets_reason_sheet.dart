part of 'sheets.dart';

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({required this.config, required this.label});

  final ConfirmConfig config;
  final String label;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}
