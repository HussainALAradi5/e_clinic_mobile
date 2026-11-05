import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/ui_text.dart';

/// Rounded search box that reports what is typed after a short pause (one request per pause, not per key),
/// with a clear button.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.hint, required this.onChanged, this.autofocus = false});

  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  static const debounce = Duration(milliseconds: 350);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _text = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _changed(String value) {
    setState(() {});
    _timer?.cancel();
    _timer = Timer(SearchField.debounce, () => widget.onChanged(value.trim()));
  }

  void _clear() {
    _timer?.cancel();
    _text.clear();
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: TextField(
      controller: _text,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: _changed,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _text.text.isEmpty
            ? null
            : IconButton(tooltip: UiText.clear, icon: const Icon(Icons.close_rounded), onPressed: _clear),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
        isDense: true,
      ),
    ),
  );
}
