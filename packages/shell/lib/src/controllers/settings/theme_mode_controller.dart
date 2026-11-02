import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light, dark or the phone's setting; remembered on this phone (not medical, so plain preferences).
class ThemeModeController extends Notifier<ThemeMode> {
  static const _prefKey = 'ec.theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.read(preferencesProvider).getString(_prefKey);
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(preferencesProvider).setString(_prefKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
