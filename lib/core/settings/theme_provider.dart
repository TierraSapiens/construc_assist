import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construc_assist/core/settings/app_themes.dart';

// Mantiene el estado del modo visual y su persistencia local.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.getBool('isObraMode') ?? true;
  }

  void setMode(bool isObra) {
    state = isObra; // Actualizamos la pantalla instantáneamente
    ref.read(sharedPrefsProvider).setBool('isObraMode', isObra); // Lo guardamos en el disco
  }
}

final isObraModeProvider = NotifierProvider<ThemeNotifier, bool>(() => ThemeNotifier());

final themeProvider = Provider<ThemeData>((ref) {
  final isObra = ref.watch(isObraModeProvider);
  return isObra ? AppThemes.obraTheme : AppThemes.oficinaTheme;
});